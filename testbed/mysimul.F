C $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/testbed/mysimul.F,v 1.1 2012/05/02 12:27:42 mlosch Exp $
C $Name:  $
      subroutine mysimul(indic,n,f,x,g,izs,rzs,dzs)
      implicit none
      integer indic, n
      double precision f,x(n),g(n)
      integer izs(*)
      real    rzs(*)
      double precision dzs(*)

      integer i
      integer iftype
      double precision twopi
      parameter ( twopi = 6.283185307179586232 )

      iftype = 2
      if (izs(1).eq.-1) then
c     generate first guess for x
       do i=1,n
        x(i)=float(i)+1.
       enddo
       if ( iftype.eq.2 ) then
        do i=1,n
         x(i)=min(x(i),+5.12D0)
         x(i)=max(x(i),-5.12D0)
        enddo
       endif
      endif
      if (indic.eq.1) then
c     do nothing, just print something
       print *, 'ml-simul, indic = ', indic, ', f = ', f
      elseif (indic.eq.4) then
       if (iftype.eq.0) then
c     compute cost function and gradient from control parameter
c     banana function ( Rosenbrock f(x,y)=(1-x)^2+100*(y-x^2)^2 )
        f=0.
        do i=1,n-1
         f=f + (1.-x(i))**2 + dzs(1)*(x(i+1)-x(i)**2)**2
        enddo
        g(:)=0.
        do i=n-1,1,-1
c        g(i)  = g(i)-2.*(1.-x(i)) - 4.5*dzs(1)*x(i)*(x(i+1)-x(i)**2)
         g(i)  = g(i)-2.*(1.-x(i)) - 4.*dzs(1)*x(i)*(x(i+1)-x(i)**2)
         g(i+1)= g(i+1)+2.*dzs(1)*(x(i+1)-x(i)**2)
        enddo
       elseif (iftype.eq.1) then
c     Himmelblau s function with 4 local minima
        f = ( x(1)**2 + x(2) - 11.D0 )**2 + ( x(1) + x(2)**2 - 7.D0 )**2
        g(1) = 4.*x(1)*( x(1)**2 + x(2) - 11.D0 ) 
     &       + 2.*( x(1) + x(2)**2 - 7.D0 )
        g(2) = 2.*( x(1)**2 + x(2) - 11.D0 ) 
     &       + 4.*x(2)*( x(1) + x(2)**2 - 7.D0 )
       elseif (iftype.eq.2) then
c     Rastrigin function
        f=10.*float(n)
        do i=1,n
         if ( x(i) .gt. 5.12D0 .or. x(i) .lt. -5.12D0) then
          print '(A,I4,A,E12.4,A)',' x(',i,') = ',x(i),', out of range'
         endif
         f = f + x(i)**2 - cos(twopi*x(i))
         g(i) = 2.*x(i) + twopi*sin(twopi*x(i))
        enddo
       else
        print *, 'iftype = ', iftype, ' not implemented'
        stop 'ABNORMAL in mysimul'
       endif
      else
       print *, 'ml-simul: indic = ', indic
       print *, 'ml-simul: should not happen'
       stop 'ABNORMAL'
      endif
      return
      end

