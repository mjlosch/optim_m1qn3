C $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/optim_store_m1qn3.F,v 1.6 2019/03/20 16:05:00 mlosch Exp $
C $Name:  $

      subroutine optim_store_m1qn3(
     I     ndz,
     U     iz,dz,niter,nsim,epsg,df1,
     I     optimcycle,
     I     store)
c     
c     subroutine optim_store_m1qn3
c     
c     Depending on the parameter store, store or restore the state of 
c     m1qn3. The communication is mostly via common blocks in order
c     to keep the changes to m1qn3 to a minimum. Only iz and dz are passed
c     as arguments
c     
      implicit none
c--   global variables
#include "m1qn3_common.h"
#include "m1qn3a_common.h"
#include "mlis3_common.h"
c--   routine arguments
      integer ndz
      integer iz(5)
      _RL dz(ndz)
      integer niter, nsim
      _RL epsg,df1
      integer optimcycle
      logical store

c--   local variables
      integer io, k
      character*(14) fname

c--   routine body
      fname = ' '
      io = 99
      if ( store ) then
       write(fname,'(A,I4.4)') 'OPWARM.opt',optimcycle+1
c
       print *
       print *, ' OPTIM_STORE_M1QN3: saving the state of m1qn3 in ',
     &      fname
       print *
c
       open(io,file=fname,form='unformatted',status='unknown')
       write(io) niter,nsim
       write(io) iz
       write(io) (dz(k),k=1,ndz)
c     some extra info
       write(io) epsg,df1
c     m1qn3_common.h
       write(io) inmemo,id,igg,idiag,iaux,ialpha,iybar,isbar,reentry
c     m1qn3a_common.h
       write(io) cold,warm,itmax,moderl,isim,jcour,d1,t,tmin,tmax,
     &      gnorm,gnorms,eps1,ff,preco,precos,ys,den,dk,dk1,ps,ps2,hp0
c     mlis3_common.h
       write(io) t_increased,indica,indicd
       write(io) tesf,tesd,fa,fpa,fn,barmin,barmul,barmax,barr,
     &      tg,fg,fpg,td,ta,d2,fp,ffn,fd,fpd,z,test,gauche,droite
      else
       write(fname,'(A,I4.4)') 'OPWARM.opt',optimcycle
c
       print *
       print *, ' OPTIM_STORE_M1QN3: restoring the state'//
     &      ' of m1qn3 from ', fname
       print *
c
       open(io,file=fname,form='unformatted',status='old')
       read(io) niter,nsim
       read(io) iz
       read(io) (dz(k),k=1,ndz)
c     some extra info
       read(io) epsg,df1
c     m1qn3_common.h
       read(io) inmemo,id,igg,idiag,iaux,ialpha,iybar,isbar,reentry
c     m1qn3a_common.h
       read(io) cold,warm,itmax,moderl,isim,jcour,d1,t,tmin,tmax,
     &      gnorm,gnorms,eps1,ff,preco,precos,ys,den,dk,dk1,ps,ps2,hp0
c     mlis3_common.h
       read(io) t_increased,indica,indicd
       read(io) tesf,tesd,fa,fpa,fn,barmin,barmul,barmax,barr,
     &      tg,fg,fpg,td,ta,d2,fp,ffn,fd,fpd,z,test,gauche,droite
      endif

      close(io)

      return
      end
