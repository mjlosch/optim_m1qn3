C $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/m1qn3a_common.h,v 1.5 2019/03/20 16:05:00 mlosch Exp $
C $Name:  $

      common /m1qn3a_l/ sscale,cold,warm
      common /m1qn3a_i/ itmax,moderl,isim,jcour
      common /m1qn3a_rl/ d1,t,tmin,tmax,gnorm,gnorms,eps1,ff,
     &     preco,precos,ys,den,dk,dk1,ps,ps2,hp0
      logical sscale,cold,warm
      integer itmax,moderl,isim,jcour
      double precision d1,t,tmin,tmax,gnorm,gnorms,eps1,ff,preco,precos,
     &    ys,den,dk,dk1,ps,ps2,hp0
