      program offline_driver
      implicit none
      integer k
      integer optimcycle
      integer maxiter
      parameter (maxiter = 10)

c     parameters to be used in m1qn3
      integer reverse
      integer n, nnn
      parameter (n = 7)
      integer impres,io,imode(3),omode,niter,nsim,iz(5),indic
      double precision x(n),f,g(n),dxmin,df1,epsg
      character*3 normtype
c     work arrays
      integer ndz, mupdate
      parameter (mupdate = 7)
      parameter (ndz=3*n + mupdate*(2*n + 1))
      double precision dz(ndz), dz2(ndz)
c     extra dummy variables
      integer nn,i
      parameter (nn = 1)
      integer izs(nn)
      real rzs(nn)
      double precision dzs(nn)

c     m1qn3 start
#include "m1qn3_common.h"
#include "m1qn3a_common.h"
#include "mlis3_common.h"
c     m1qn3 end

      character*(*) fname
      parameter ( fname = 'output_m1qn3.txt' )

      external simul_rc,euclid,ctonbe,ctcabe

c      if (ndz.gt.1000) stop 'ndz >1000, increase dz'
c     initialization
      epsg = 1.d-8
      impres = 6
      io=98
      optimcycle=0
      normtype = 'two'
      f = 0.
      dxmin = 1.d-6
      df1 = 10.
c     diagonal scaling mode
      imode(1) = 0
c     cold start
      imode(2) = 0
c     call simul with indic=1 every imode(3)th iteration
      imode(3) = 0
c     set this output variable to check if anything is done to it in m1qn3
c     value does not alter results
      omode=-1
      reverse=1
      niter = 1000
      nsim  = 10000
      do k=1,5
       iz(k)=0
      enddo
      indic=4
      do k=1,n
       x(k) = 0.
       g(k) = 0.
      enddo
      do k=1,nn
       izs(k)=0
       rzs(k)=0.
       dzs(k)=0.
      enddo
      dzs(1) = 100.
c     restart stuff
      do k=1,ndz
       dz(k) = 0.
      enddo
      dz(:)=0.
c     end restart stuff
      do i=1,n
       x(i) = 0.
      enddo
      f=0.

      open(11,file='count.txt',status='old')
      read(11,*) optimcycle
      close(11)

c     first guess of x,f,g
      if ( optimcycle.eq.0 ) then
c     cold start
       print *, 'cold start'
       imode(2)=0
c     first guess (izs=-1)
       call mysimul(indic,n,f,x,g,-1,rzs,dzs)
       df1 = f*0.1
       reentry=0
       open(io,file=fname,status='unknown')
      else
c     warm restart
       imode(2)=1
c     read restart information
       call optim_store_m1qn3(ndz,iz,dz,niter,nsim,epsg,df1,
     I      optimcycle,
     I      .false.)
       open(99,file='model_out',status='old',form='unformatted')
       read(99) indic,nnn
       read(99) f
       if ( nnn.ne.n ) stop 'nnn .ne. n'
       read(99) (g(i),i=1,n)
       read(99) izs,rzs,dzs
       close(99)
       open(99,file='model_in',status='old',form='unformatted')
       read(99) indic,nnn
       read(99) (x(i),i=1,nnn)
       read(99) izs,rzs,dzs
       close(99)
       df1 = -2.e23
       open(io,file=fname,status='old',position='append')
      endif

      reverse=1
      call m1qn3_offline
     &     (simul_rc,euclid,ctonbe,ctcabe,n,x,f,g,dxmin,df1,
     &     epsg,normtype,impres,io,imode,omode,niter,nsim,
     &     iz,dz,ndz,reverse,indic,izs,rzs,dzs)
      close(io)
c     write restart information
       call optim_store_m1qn3(ndz,iz,dz,niter,nsim,epsg,df1,
     I      optimcycle,
     I      .true.)

      open(99,file='model_in',status='unknown',form='unformatted')
      write(99) indic,n
      write(99) (x(i),i=1,n)
      write(99) izs,rzs,dzs
      close(99)


      if ( reverse .le. 0 ) then
       print *, 'stoptheloop'
       print *, 'ml-offline_driver: niter = ',niter
       print *, 'ml-offline_driver: nsim  = ',nsim
       print *, 'ml-offline_driver: omode = ',omode
      endif
      stop 'NORMAL END'

      end
