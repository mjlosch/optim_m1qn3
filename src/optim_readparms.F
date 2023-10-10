C     ECCO_CPPOPTIONS used to affect maxcvars and defined ALLOW_OBCS?_CONTROL
C#include "ECCO_CPPOPTIONS.h"
C     now:
C     CTRL_OPTIONS affects maxcvars and may define ALLOW_OBCS?_CONTROL
#include "CTRL_OPTIONS.h"

      subroutine optim_readparms(
     O                    nn, ff
     &                  )

c     ==================================================================
c     subroutine optim_readparms
c     ==================================================================
c
c     o initialise some global variables
c     o Read namelist files and
c     o read the number of control variables and return it as nn
c     o read the cost function value from ctrlname and return as ff,
c       note that this value is only meaning full in the first iteration
c
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#if (defined (ALLOW_GENARR2D_CONTROL) || defined (ALLOW_GENARR3D_CONTROL) || defined (ALLOW_GENTIM2D_CONTROL))
# include "CTRL_SIZE.h"
#endif
#include "CTRL.h"
#include "optim.h"

c     == routine arguments ==

      integer nn

c     == local variables ==

      integer il
      integer errio

      _RL            ff
      _RL            dfminFrac

#ifdef DYNAMIC
      _RL            vv(nn)
#else
      integer nmax
      parameter( nmax = MAX_INDEPEND )
      _RL   vv(nmax)
#endif

      character*(max_len_prec) record

c     == external ==

      integer  ilnblnk

c     == end of interface ==

      namelist /CTRL_PACKNAMES/
     &     yadmark, ctrlname, costname, scalname, maskname, metaname,
     &     yctrlid, yctrlposunpack, yctrlpospack

      namelist /OPTIM/
     &                      optimcycle,
     &                      numiter, nfunc, fmin, dfminFrac, iprint,
     &                      epsf, epsx, epsg,
     &                      nupdate, eps

      namelist /M1QN3/
     &     coldStart

c--   Initialise myx/ygloballo to one. In the MITgcm they are set 
c     in ini_procs.F according to the current mpi-process, but here 
c     we can just set them to 1 because we do not anticipate, to 
c     ever run this program in a multprocessor environment.
      myygloballo = 1
      myxgloballo = 1

c--   Preset the optimization parameters.
      optimcycle =  0
      nvars      =  0
      numiter    =  1
      nfunc      =  1
      fmin       =  UNSET_RL
      dfminFrac  =  0.0
      iprint     =  10
      epsx       =  1.e-6
      epsg       =  1.e-6
      eps        = -1.e-6
      nupdate    =  1
      ff         = 0.
cdfer      expId      = 'MIT_CE_000'
      yctrlid    = 'MIT_CE_000'
      yctrlposunpack      = '.opt'
      yctrlpospack        = '.opt'
      ctrlname            = 'ecco_ctrl'
      costname            = 'ecco_cost'
      scalname            = ' '
      maskname            = ' '
      metaname            = ' '
      coldStart  = .false.

      modeldataunit = 14
      scrunit1      = 11

c--   Read control parameters from file.
      open(unit=scrunit1,status='scratch')

      open(unit = modeldataunit,file = 'data.ctrl',
     &     status = 'old', iostat = errio)
      if ( errio .lt. 0 ) then
       stop ' stopped in optim_readparms while opening data.ctrl'
      endif

      do while ( .true. )
       read(modeldataunit, fmt='(a)', end=21) record
       il = max(ilnblnk(record),1)
       if ( record(1:1) .ne. commentcharacter )
     &      write(unit=scrunit1, fmt='(a)') record(:il)
      enddo
   21 continue
      close( modeldataunit )

      rewind( scrunit1 )
      read(unit = scrunit1, nml = ctrl_packnames)
      close( scrunit1 )
      print*, ' OPTIM_READPARMS: Control options have been read.'

c--   Read optimization parameters from file.
      open(unit=scrunit1,status='scratch')

      open(unit = modeldataunit,file = 'data.optim',
     &     status = 'old', iostat = errio)
      if ( errio .lt. 0 ) then
       stop ' stopped in optim_readparms while opening data.optim'
      endif

      do while ( .true. )
       read(modeldataunit, fmt='(a)', end=22) record
       il = max(ilnblnk(record),1)
       if ( record(1:1) .ne. commentcharacter )
     &      write(unit=scrunit1, fmt='(a)') record(:il)
      enddo
   22 continue
      close( modeldataunit )

      rewind( scrunit1 )
      read(unit = scrunit1, nml = optim)
      read(unit = scrunit1, nml = m1qn3)
      close( scrunit1 )
      print*, ' OPTIM_READPARMS: Minimization options have been read.'

      if (eps .gt. 0.0) then
        epsf = eps
        epsx = eps
        epsg = eps
      endif
c     always force cold start for the 0th cycle
      if ( optimcycle .eq. 0 ) coldStart=.true.

c     read header from costname rather than ctrlname, because the
c     cost function value in costname is what we need, ctrlname only
c     contains a valid cost function value for the 0th iteration
      call optim_readdata ( nn, costname, .true., ff, vv)

      if ( dfminFrac.lt.0.0 .or. dfminFrac.ge.1.0) then
       print*, ' OPTIM_READPARMS: dfminFrac = ', dfminFrac,
     &      ' should be > 0 and < 1'
       stop 'S/R OPTIM_READPARMS: ABNORMAL END'
      endif
      if ( dfminFrac.ne.0.0 ) dfminFrac = 1.0 - dfminFrac
      if ( fmin.eq.UNSET_RL ) then
       if ( coldStart ) then
c     only in this case does ff contain the actual cost function value
        fmin = dfminFrac*ff
       else
c     otherwise we (ab-)use the file ctrlname for storing fmin
        fmin = ff
       endif
      endif
      if ( coldStart ) then
       if ( fmin.le.0.0 ) then
        print '(A,E12.6,A)', ' OPTIM_READPARMS: fmin = ', fmin,
     &       ' should be > 0'
        stop 'S/R OPTIM_READPARMS: ABNORMAL END'
       endif
       if ( fmin.gt.ff ) then
        print '(A,E12.6,A,E12.6)', ' OPTIM_READPARMS: fmin = ', fmin,
     &       ' should be < ff = ', ff
        stop 'S/R OPTIM_READPARMS: ABNORMAL END'
       endif
      endif

c--   Do some final printout.
      print*
      print*, ' OPTIM_READPARMS: Iteration number = ', optimcycle
      print*, ' number of control variables       = ', nn
      print*, ' cost function value in ', ctrlname, '  = ', ff
      if ( coldStart ) then
       print*, ' expected cost function minimum    = ', fmin
       print*, ' expected cost function decrease   = ', ff-fmin
      endif
      print '(a,4a,i4.4)',
     &     '  Data will be read from the following file: ',
     &     ctrlname,'_',yctrlid(1:10),'.opt', optimcycle
      print*

      return
      end

CStartOfInterface
      INTEGER FUNCTION ILNBLNK( string )
C     /==========================================================\
C     | FUNCTION ILNBLNK                                         |
C     | o Find last non-blank in character string.               |
C     \==========================================================/
      IMPLICIT NONE
      CHARACTER*(*) string
CEndOfInterface
      INTEGER L, LS
C
      LS      = LEN(string)
      ILNBLNK = LS
      DO 10 L = LS, 1, -1
        IF ( string(L:L) .EQ. ' ' ) GOTO 10
         ILNBLNK = L
         GOTO 11
   10 CONTINUE
   11 CONTINUE
C
      RETURN
      END
