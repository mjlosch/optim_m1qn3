# $Header: /u/gcmpack/MITgcm_contrib/mlosch/optim_m1qn3/testbed/Makefile,v 1.2 2019/02/12 15:51:48 mlosch Exp $
# $Name:  $
MAKEFILE=Makefile

SRC		=	ddot.F			\
			optim_store_m1qn3.F	\
                        m1qn3_offline.F		\
                        mysimul.F  		\
                        offline_driver.F                          

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

INCLUDEDIRS     = -I. -I../src

LIBDIRS         = 
LIBS            = 

# The cpp flags.
CPPFLAGS = -DREAL_BYTE=4		\
	-DMAX_INDEPEND=1000000		\
	-D_RL='double precision'	\
	-D_RS='double precision'

LN=ln -s
#                -DMAX_INDEPEND=293570968        \
# FORTRAN compiler and its flags.
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

SMALLF      = $(SRC:.F=.$(SUFF))
OBJECTS     = $(SRC:.F=.o)

.SUFFIXES:
.SUFFIXES: .o .$(SUFF) .F

all: small_f offline_driver model driver

offline_driver: $(OBJECTS)
	$(FC) -o $@ $(FFLAGS) $(OBJECTS) $(LIBDIRS) $(LIBS)
model: model.o mysimul.o
	$(FC) -o $@ $(FFLAGS) model.o mysimul.o
driver: driver.o m1qn3.o ddot.o mysimul.o
	$(FC) -o $@ $(FFLAGS) ddot.o m1qn3.o driver.o mysimul.o

links: $(SRC)

small_f: $(SMALLF)

depend:
	makedepend -o .$(SUFF) $(INCLUDEDIRS) $(SRC)

# The normal chain of rules is (  .F - .f - .o  )
.F.f:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.F.for:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIRS) > $@
.f.o:
	$(FC) $(FFLAGS) -c $<
.for.o:
	$(FC) $(FFLAGS) -c $<

# Cleaning options.
scratch:
	-rm -f OPWARM.* model_in model_out *.txt

cleanlinks:
	-find . -type l -exec rm {} \;

clean:
	-rm -f *.o *.f *.for

Clean:
	@make -f $(MAKEFILE) clean
	@make -f $(MAKEFILE) cleanlinks
	@make scratch 

CLEAN:
	@make -f $(MAKEFILE) Clean
	-rm -f offline_driver model driver

ddot.F optim_store_m1qn3.F m1qn3_offline.F:
	if [ ! -L $@ ]; then $(LN) ../src/$@ $@; fi

# DO NOT DELETE

