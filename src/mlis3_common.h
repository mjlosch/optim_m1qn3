C $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/mlis3_common.h,v 1.3 2012/05/02 20:15:16 mlosch Exp $
C $Name:  $    

      common /mlis3_l/ t_increased
      common /mlis3_i/ indica,indicd
      common /mlis3_rl/ tesf,tesd,fa,fpa,fn,barmin,barmul,barmax,barr,
     &     tg,fg,fpg,td,ta,d2,fp,ffn,fd,
     &     fpd,z,test,gauche,droite
      logical t_increased
      integer indica,indicd
      double precision tesf,tesd,fa,fpa,fn,barmin,barmul,barmax,barr
      double precision tg,fg,fpg,td,ta,d2,fp,ffn,fd,
     &     fpd,z,test,gauche,droite
