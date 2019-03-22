c $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/optim_main.F,v 1.3 2018/05/03 11:26:05 mlosch Exp $
c $Name:  $
c     ==================================================================
c
c     optim2: Routines for doing an off-line optimization with m1qn3
c             after the ECCO forward and adjoint model have been run.
c
c     optim_main - driver routine
c     - optim_readparms   :: read namelist files and number of control 
c                            parameters
c     - optim_sub         :: driver for m1qn3
c       + optim_readdata  :: read control vector or gradient and cost 
c                           function
c       + optim_writedata :: write control vector
c       + optim_store_m1qn3 :: store/restore the state of the optimizer
c       + m1qn3_offline     :: optimization routine
c         > ddot            :: LAPACK routine, required by m1qn3_offline
c
c     Documentation:
c
c     m1qn3_offline is based on m1qn3 v3.3, downloaded here:
c     https://who.rocq.inria.fr/Jean-Charles.Gilbert/modulopt/
c             optimization-routines/m1qn3/m1qn3.html
c     To make work offline, the "save" statement have been replace
c     by common blocks, by which variables are passed to
c     optim_store_m1qn3 where they are stored on disk. In order to
c     reduce the number of variables to be saved, some have been move
c     down to where they are first used, e.g. barmul, tesf, etc.
c     
c     The driver routines optime_*.F are adapted from the original
c     optim-pkg of the MITgcm.
c
c     Martin.Losch@awi.de 24-Apr-2012
c
c     ==================================================================

      program optim_main

c     ==================================================================
c     program optim_main
c     ==================================================================
c
c     o Driver routine for the ECCO optimization package.
c     ==================================================================

      implicit none

c     == global variables ==

c     == routine arguments ==

c     == local variables ==

      integer nn
      _RL     ff

c     == end of interface ==

c--   Headline.
      print*
      print*,' =================================================='
      print*,' Large Scale Optimization with off-line capability.'
      print*,' =================================================='
      print*

c--   Get the number of control variables and other namelist 
c     parameters 
      nn=1
      ff=-9999.
      call optim_readparms( nn, ff )

c--   Call the subroutine that will set up the optimization routine
      call optim_sub( nn, ff )

c--   Succesful termination.
      print*
      print*,' ======================================'
      print*,' Large Scale Optimization run finished.'
      print*,' ======================================'
      print*
      end
