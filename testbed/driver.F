C $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/testbed/driver.F,v 1.2 2012/05/07 12:09:27 mlosch Exp $
C $Name:  $
      program driver
      implicit none
      integer i,k
      integer iiter, maxiter
      parameter (maxiter = 10)
      logical testrestart

c     parameters to be used in m1qn3
      integer reverse
      integer n
      parameter (n = 7)
      integer impres,io,imode(3),omode,niter,nsim,iz(5),indic
      double precision x(n),f,g(n),dxmin,df1,epsg
      character*3 normtype
c     work arraydz
      integer ndz, mupdate
      parameter (mupdate = 7)
      parameter (ndz=3*n + mupdate*(2*n + 1))
      double precision dz(ndz)
c     extra dummy variables
      character*(80) fmt
      integer nn
      parameter (nn = 1)
      integer izs(nn)
      real rzs(nn)
      double precision dzs(nn)

      external simul_rc,euclid,ctonbe,ctcabe

c     initialization
      testrestart=.false.
      normtype = 'two'
      f = 0.
      dxmin = 1.d-6
      df1 = 10.
      epsg = 1.d-8
      impres = 6
      io=99
c     diagonal scaling mode
      imode(1) = 0
c     cold start
      imode(2) = 0
c     call simul with indic=1 every imode(3)th iteration
      imode(3) = 0
      omode=1
      reverse=1
      niter = 1000
      nsim  = 1000
      do i=1,5
       iz(i)=0
      enddo
      indic=4
      do i=1,n
       x(i) = 0.
       g(i) = 0.
      enddo
      do i=1,nn
       izs(i)=0
       rzs(i)=0.
       dzs(i)=0.
      enddo
      dzs(1) = 100.
      open(io,file='output_m1qn3_driver.txt',status='unknown')
c     first guess of x,f,g (izs=-1)
      call mysimul(indic,n,f,x,g,-1,rzs,dzs)
      print *, 'ml-driver x = ', (x(i),i=1,n)
      print *, 'ml-driver f = ', f
      print *, 'ml-driver g = ', (g(i),i=1,n)
      df1 = f*0.1
      iiter = 0
      if ( testrestart ) then
       niter=1
       do iiter=1,niter

        call m1qn3 (simul_rc,euclid,ctonbe,ctcabe,n,x,f,g,dxmin,df1,
     &       epsg,normtype,impres,io,imode,omode,niter,nsim,
     &       iz,dz,ndz,reverse,indic,izs,rzs,dzs)
        write(fmt,'(A,I4,A)') '(A,I4,I8,',n,'E12.4)'
        write(*,fmt) 'ml-driver iter = ',iiter,reverse, (1.-x(i),i=1,n)
        call mysimul(indic,n,f,x,g,izs,rzs,dzs)
        write(fmt,'(A,I4,A)') '(A,',n+1,'E12.4)'
        write(*,fmt) 'ml-driver f    = ', f, (g(i),i=1,n)
c        print *, 'ml-driver: niter = ', niter, nsim
        if ( reverse .lt. 0 ) goto 100
        
       enddo
 100   continue
       reverse = 1
       imode(2)=1
       niter = 2
       nsim=5000
       iiter=iiter-1
      endif
c
      do while ( reverse.eq.1 )
       iiter=iiter+1
       call m1qn3 (simul_rc,euclid,ctonbe,ctcabe,n,x,f,g,dxmin,df1,
     &      epsg,normtype,impres,io,imode,omode,niter,nsim,
     &      iz,dz,ndz,reverse,indic,izs,rzs,dzs)
       write(fmt,'(A,I4,A)') '(A,I4,I8,',n,'E12.4)'
       write(*,fmt) 'ml-driver iter = ',iiter,reverse, (1.-x(i),i=1,n)
       call mysimul(indic,n,f,x,g,izs,rzs,dzs)
       write(fmt,'(A,I4,A)') '(A,',n+1,'E12.4)'
       write(*,fmt) 'ml-driver f    = ', f, (g(i),i=1,n)
c       print *, 'ml-driver niter =', niter, nsim
      enddo
      close(io)
      
      print *, 'ml-driver: niter = ',niter
      print *, 'ml-driver: nsim  = ',nsim
      print *, 'ml-driver: omode = ',omode

      stop 'NORMAL END'
      end
