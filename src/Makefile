#***********************************************************************
# Makefile for the off-line large scale optimization with m1qn3
# in reverse communication mode.
#
# started: Martin Losch Martin.Losch@awi.de 24-Apr-2012
#
# changed: 
#
#***********************************************************************

MAKEFILE=Makefile
# The optimization routines.
SRC		=	optim_main.F			\
			optim_sub.F			\
			optim_readparms.F		\
			optim_readdata.F		\
			optim_writedata.F		\
			optim_store_m1qn3.F		\
                        m1qn3_offline.F			\
                        ddot.F                          

EXEDIR     = .

# default suffix for pre-processed fortran files is f
SUFF=f
# for case-insensitive file systems you may need this
# SUFF=for
# Location of cpp preprocessor
# default is (Linux)
CPP             = cat $< | /lib/cpp -P -traditional
# Mac OS X
# CPP             = cat $< | /usr/bin/cpp -P -traditional
# on SUNOS
# CPP		= cat $< | /usr/ccs/lib/cpp

MAKEDEPEND=makedepend
# this works when you done have a makedepend
#MAKEDEPEND=../../MITgcm/tools/xmakedepend

INCLUDEDIRS     = -I.				\
		  -I../../MITgcm/verification/tutorial_global_oce_optim/build

LIBDIRS         = 
LIBS            = 

EXECUTABLE      = $(EXEDIR)/optim.x

# The cpp flags.
CPPFLAGS = -DREAL_BYTE=4		\
	-DMAX_INDEPEND=1000000		\
	-D_RL='double precision'	\
	-D_RS='double precision'	\
	-D_d='d'

#                -DMAX_INDEPEND=293570968        \
# FORTRAN compiler and its flags.
# It is important that byte conversion flags are consistent between this
# compilation and the mitgcmuv compilation
# default is gfortran
FC              = gfortran
FFLAGS          =  -fconvert=big-endian

# ifort compilers
#FC              = ifort
#FFLAGS          = -mieee-fp -132 -r8 -i4 -W0 -WB -CB -fpe0 -traceback -convert big_endian -assume byterecl

# SGI o3k IRIX64
#FC              = f77
#FFLAGS          = -extend_source -bytereclen -mips4 -r8 -static

# AER cluster
#FC		= /opt/mpich/bin/mpif77
#FFLAGS		= -byteswapio -r8 -Mnodclchk -Mextend

# Cray compiler
#FC     = ftn
#FFLAGS =  -h byteswapio -hnoomp -O0 -hfp0

SMALLF      = $(SRC:.F=.$(SUFF))
OBJECTS     = $(SRC:.F=.o)

.SUFFIXES:
.SUFFIXES: .o .$(SUFF) .F

all: small_f $(EXECUTABLE)
$(EXECUTABLE): $(OBJECTS)
	$(FC) -o $@ $(FFLAGS) $(OBJECTS) $(LIBDIRS) $(LIBS)

small_f: $(SMALLF)

depend:
	$(MAKEDEPEND) -o .$(SUFF) $(INCLUDEDIRS) $(SRC)

# The normal chain of rules is (  .F - .f - .o  )
.F.for:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.for.o:
	$(FC) $(FFLAGS) -c $<
.F.f:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.f.o:
	$(FC) $(FFLAGS) -c $<

# Cleaning options.
clean:
	-rm -f *.o *.f *.for

Clean:
	@make -f $(MAKEFILE) clean
	-rm -f OPWARM.*

CLEAN:
	@make -f $(MAKEFILE) Clean
	-rm -f $(EXECUTABLE)

# DO NOT DELETE

