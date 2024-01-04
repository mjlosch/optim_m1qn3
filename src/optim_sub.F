C     ECCO_CPPOPTIONS used to affect maxcvars and defined ALLOW_OBCS?_CONTROL
C#include "ECCO_CPPOPTIONS.h"
C     now:
C     CTRL_OPTIONS affects maxcvars and may define ALLOW_OBCS?_CONTROL
#include "CTRL_OPTIONS.h"

      subroutine optim_sub(
     I                 nn, ff
     &               )

c     ==================================================================
c     subroutine optim_sub
c     ==================================================================
c
c     o This is the main driver routine for the offline version of
c       m1qn3 (m1qn3_offline). It
c       - sets all m1qn3 relevant parameters
c       - reads the model state (control vector, cost function,
c         and gradient)
c       - reads the state of m1qn3_offline
c       - calls m1qn3_offline
c       - saves model state (control vector) and state of m1qn3_offline
c     The routine is somewhat lengthy and could be split into separate
c     subroutines, but I felt that it was easier to write and test it
c     in this form
c     Martin Losch (Martin.Losch@awi.de), Apr, 2012
c
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"

#include "CTRL_SIZE.h"
#include "CTRL.h"
#include "optim.h"
#include "m1qn3_common.h"

c     == routine arguments ==

      integer nn
      _RL ff

c     == local variables ==

      _RL   objf

#ifdef DYNAMIC
      _RL, dimension(:), allocatable :: xx, adxx
#else
      integer nmax
      parameter( nmax = MAX_INDEPEND )
      _RL   xx(nmax)
      _RL   adxx(nmax)
#endif
      _RL  xxmean

CML      logical coldStart
c     formal parameters of m1qn3
      integer reverse
      integer impres,imode(3),omode,niter,nsim,iz(5),indic
      _RL dxmin,df1
      character*3 normtype
c     work arrays
      integer ndz
CML      _RL dz(ndz)
      double precision, dimension(:), allocatable :: dz
c     extra dummy variables
      integer izs(1)
      _RS rzs(1)
      _RL dzs(1)
      integer, parameter :: io = 60
      character*(*), parameter :: fname_m1qn3 = 'm1qn3_output.txt'
c     end of m1qn3 parameters

      integer i

c     == external ==

      external simul_rc,euclid,ctonbe,ctcabe

c     == end of interface ==

c--   Allocate memory for the control variables and the gradient vector.
#if defined(DYNAMIC)
      allocate(   xx(nn) )
      allocate( adxx(nn) )
#endif

#ifndef DYNAMIC
      if (nn .gt. nmax) then
        print*,' OPTIMUM: Not enough space.'
        print*,'          nmax = ',nmax
        print*,'            nn = ',nn
        print*
        print*,'          Set MAX_INDEPEND in Makefile .ge. ',nn
        print*
        stop   ' ... stopped in OPTIMUM.'
      endif
#endif

      print*, ' OPTIM_SUB: Calling m1qn3_optim for iteration: ',
     &     optimcycle
      print*, ' OPTIM_SUB: with nn, REAL_BYTE = ', nn, REAL_BYTE

c     can be 'two','sup','dfn', see m1qn3 documentation for details
      normtype='two'
c     after reading data.optim some of these parameter values can be guessed
c     impres=6, impres determines the amount of m1qn3-output see documentation
      impres=iprint
c     these should strictly be different (nsim>niter), but in practice
c     it does not matter
      niter   = numiter
      nsim    = nfunc*niter
c     epsg=1.d-8
      dxmin=epsx
c     will be set later
      df1=-UNSET_RL
c
      imode=(/0,1,0/)
      omode=-1
c     initialise work array
      ndz = 4*nn+nupdate*(2*nn+1)
      do i=1,5
       iz(i)=0
      enddo
      allocate(dz(ndz))
      do i=1,ndz
       dz(i) = 0.
      enddo
c     these alway have to be set like this
      reverse=1
      indic=4
c     initialise the dummy arguments that are not used
      izs(1)=UNSET_I
      rzs(1)=UNSET_RS
      dzs(1)=UNSET_RL

c--   first read the model output into xx, adxx, and cost function
c     value into objf
#if defined(DYNAMIC)
      do i = 1,nn
#else
c     make sure that really everything is initialized
      do i = 1,nmax
#endif
       xx(i)   = 0.
       adxx(i) = 0.
      enddo
c
      print *, ' OPTIM_SUB: read model state'
      call optim_readdata( nn, ctrlname, .false., objf,   xx )
      call optim_readdata( nn, costname, .false., objf, adxx )
      print *, ' OPTIM_SUB after reading ',
     &           ctrlname, ' and ', costname, ':'
      print *, ' OPTIM_SUB          nn = ', nn
      print *, ' OPTIM_SUB        objf = ', objf
      print *, ' OPTIM_SUB       xx(1) = ', xx(1), xx(2)
      xxmean = sum(xx(1:nn))/dble(nn)
      print *, ' OPTIM_SUB:   mean(xx) =', xxmean
      print *, ' OPTIM_SUB:    max(xx) =', maxval(xx(1:nn))
      print *, ' OPTIM_SUB:    min(xx) =', minval(xx(1:nn))
      print *, ' OPTIM_SUB:    std(xx) =',
     &     sum((xx(1:nn)-xxmean)**2)/dble(nn)
      print *, ' OPTIM_SUB    adxx(1)  = ', adxx(1), adxx(2)
      xxmean = sum(adxx(1:nn))/dble(nn)
      print *, ' OPTIM_SUB: mean(adxx) =', xxmean
      print *, ' OPTIM_SUB:  max(adxx) =', maxval(adxx(1:nn))
      print *, ' OPTIM_SUB:  min(adxx) =', minval(adxx(1:nn))
      print *, ' OPTIM_SUB:  std(adxx) =',
     &     sum((adxx(1:nn)-xxmean)**2)/dble(nn)

      if ( coldStart ) then
c--   cold start
       print *, ' OPTIM_SUB: cold start, optimcycle =', optimcycle
       imode(2) = 0
c     this variable is the only one of the m1qn3-related common blocks
c     that needs to be initialized here to make sure that we have a
c     clean start
       reentry  = 0
c     compute expected decrease of cost function from objf and fmin;
c     this value is only used for a cold start of m1qn3_offline, for a
c     warm start df1 is overwritten with data from a restart file
       df1=objf-fmin
       if ( df1 .le. 0. ) then
        print *, ' OPTIM_SUB: df1 = objf-fmin = ', df1,
     &       ' but should be > 0.'
        stop 'ABNORMAL in S/R OPTIM_SUB'
       endif

c     open output file for m1qn3
       open(io,file=fname_m1qn3,status='unknown')
      else
c--   warm restart
c     requires restoring the state of m1qn3 with pickup file
       print *, ' OPTIM_SUB: warm start, optimcycle =', optimcycle
       imode(2) = 1
       call optim_store_m1qn3(ndz,iz,dz,niter,nsim,epsg,df1,
     I      optimcycle,
     I      .false.)
c     re-open output file for m1qn3
       open(io,file=fname_m1qn3,status='old',position='append')
      endif

c--   call the minimizer, a slightly modified version of m1qn3 v3.3
c     (Gilbert & Lemarechal, 1989), downloaded in April 2012.
c     simul_rc,euclid,ctonbe,ctcabe are external subroutines that
c     are provided within m1qn3. euclid, ctonbe, ctcabe can be replaced
c     by something more efficient, simul_rc is a dummy routine for
c     the reverse communication mode and should not be changed.
      print *, ' OPTIM_SUB: call m1qn3_offline ........'
      call m1qn3_offline (simul_rc,euclid,ctonbe,ctcabe,
     &     nn,xx,objf,adxx,dxmin,df1,
     &     epsg,normtype,impres,io,imode,omode,niter,nsim,
     &     iz,dz,ndz,reverse,indic,izs,rzs,dzs)
      close(io)
      print *, ' OPTIM_SUB: ...........................'
      print *, ' OPTIM_SUB: returned from m1qn3_offline'
      print *, ' OPTIM_SUB:      nn = ', nn
      print *, ' OPTIM_SUB:   xx(1) = ', xx(1), xx(2)
      print *, ' OPTIM_SUB: adxx(1) = ', adxx(1), adxx(2)
      print *, ' OPTIM_SUB: omode   = ', omode
      print *, ' OPTIM_SUB: niter   = ', niter
      print *, ' OPTIM_SUB: nsim    = ', nsim
      print *, ' OPTIM_SUB: reverse = ', reverse

c     compute min/max/mean/std of output vector see if it is within
c     reasonable bounds (prior to scaling)
      xxmean = sum(xx(1:nn))/dble(nn)
      print *
      print *,' OPTIM_SUB: mean(xx) =', xxmean
      print *,' OPTIM_SUB:  max(xx) =', maxval(xx(1:nn))
      print *,' OPTIM_SUB:  min(xx) =', minval(xx(1:nn))
      print *,' OPTIM_SUB:  std(xx) =',
     &     sum((xx(1:nn)-xxmean)**2)/dble(nn)
      print *
c     write state of m1qn3 into pickup file for warm restart
c     even if the iteration has terminated with a defined omode state,
c     because we would like to be able to do a warm restart with
c     modified parameters.
c     if ( reverse .eq. 1 ) call optim_store_m1qn3(
      call optim_store_m1qn3(
     I     ndz,iz,dz,niter,nsim,epsg,df1,
     I     optimcycle,
     I     .true.)
c     write model control vector
      print *,' OPTIM_SUB: writing ', nn,' sized control to file ',
     &     ctrlname
c     give the cost function a funny value to make sure that nobody
c     mistakes it for the real one
      call optim_writedata( nn, ctrlname, .false., -9999. _d 0, xx )

c     clean up
#ifdef DYNAMIC
      deallocate(xx, adxx)
#endif /* DYNAMIC */
      deallocate(dz)

c     stopping criterion
      if ( reverse .lt. 0 ) then
       print *, ' OPTIM_SUB: reverse                            = ',
     &      reverse
       print *, ' OPTIM_SUB: optimization terminated with omode = ',
     &      omode
       stop 'ABNORMAL in S/R OPTIM_SUB'
      endif

      return
      end
