##-------------------------------------------------------------------##
##     Makefile for compiling SPLASH and linking with PGPLOT         ##
##     Written by Daniel Price					     ##
##     University of Exeter, UK, 2006                    	     ##
##                                                                   ##
##     requires GNU make (on some systems this is 'gmake' instead    ##
##                        of 'make')                                 ##
##                                                                   ##
##     see the INSTALL file for detailed installation instructions   ##
##-------------------------------------------------------------------##


.KEEP_STATE:
KNOWN_SYSTEM=no
#
# some default settings for unix systems
#
F90C= 
F90FLAGS=
X11LIBS= -L/usr/X11R6/lib -lX11
#
# change the line below depending on where/how you have installed PGPLOT
# (some settings of the SYSTEM variable for specific machines overwrite this)
#
PGPLOTLIBS = -L$(PGPLOT_DIR) -lpgplot -lpng -lg2c
#
# this file contains system-dependent routines like getarg, iargc etc.
#
SYSTEMFILE= system_unix.f90
#
# this can be used to statically link the pgplot libraries if all else fails
#
STATICLIBS=
#
# set the parallel flag to yes to compile with openMP directives
#
#PARALLEL=no
#
# the openMP flags should be set in the lines defining your system type
# (ie. leave line below blank)
OMPFLAGS=
#
# the endian flag can be used to compile the code to read BIG or LITTLE endian data
# some compilers also allow this to be done at runtime (e.g. g95, ifort) by setting
# an environment variable appropriately (e.g. G95_ENDIAN or F_UFMTENDIAN)
#
#ENDIAN=
#ENDIAN='BIG'
#ENDIAN='LITTLE'

#--------------------------------------------------------------
#  the following are general settings for particular compilers
#
#  set the environment variable 'SYSTEM' to one of those
#  listed to use the appropriate settings
#
#  e.g. in tcsh use
#  setenv SYSTEM 'g95'
#
#  in bash the equivalent is
#  export SYSTEM='g95'
#
#--------------------------------------------------------------

ifeq ($(SYSTEM),g95)
#  using the g95 compiler
   F90C= g95
   F90FLAGS= -O3 -ffast-math
   SYSTEMFILE= system_f2003.f90 # this is for Fortran 2003 compatible compilers
   DEBUGFLAG= -Wall -Wextra -g -fbounds-check -ftrace=full
   ENDIANFLAGBIG= -fendian='BIG'
   ENDIANFLAGLITTLE= -fendian='LITTLE'
   PARALLEL= no
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM), gfortran)
#  gfortran compiler (part of gcc 4.x.x)
   F90C= gfortran
   F90FLAGS= -O3 -Wall
   SYSTEMFILE= system_unix.f90
   DEBUGFLAG= -g -frange-check
   OMPFLAG= -fopenmp
   ENDIANFLAGBIG= -fconvert=big-endian
   ENDIANFLAGLITTLE= -fconvert=little-endian
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),nagf95)
#  NAG f95 compiler
   F90C= f95
   F90FLAGS= -O3
   SYSTEMFILE= system_unix_NAG.f90
   PARALLEL= no
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),sunf95)
#  sun f95 compiler on linux
   F90C= sunf95
   F90FLAGS= -fast -ftrap=%none
   OMPFLAGS= -openmp
   DEBUGFLAG= -g -C -w4 -errtags -erroff=COMMENT_1582,COMMENT_1744 -ftrap=%all
   SYSTEMFILE= system_f2003.f90
   ENDIANFLAGBIG= -xfilebyteorder=big16:%all
   ENDIANFLAGLITTLE= -xfilebyteorder=little16:%all
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),ifort)
#  this is for the intel fortran compiler
   F90C= ifort
   F90FLAGS= -O3 -Vaxlib -nbs
   OMPFLAGS= -openmp
   SYSTEMFILE= system_f2003.f90
   ENDIANFLAGBIG= -convert big_endian
   ENDIANFLAGLITTLE= -convert little_endian
# or use setenv F_UFMTENDIAN=big or little at runtime
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),pgf90)
#  this is for the Portland Group Fortran 90 compiler
   F90C= pgf90
   F90FLAGS= -O -Mbackslash
   SYSTEMFILE= system_unix.f90
   KNOWN_SYSTEM=yes
endif

#--------------------------------------------------------------
#
# the following presets are machine-specific
# (ie. relate to both the compiler and a specific
#      installation of pgplot)
#
#--------------------------------------------------------------

ifeq ($(SYSTEM),ukaff1a)
#  this is for ukaff1a
   F90C= xlf90_r
   F90FLAGS= -O3 -qnoescape -qsuffix=f=f90 -qextname
   OMPFLAGS= -qsmp=noauto
   SYSTEMFILE= system_f2003.f90
   PGPLOTLIBS= -L/home/dprice/pgplot -lpgplot  
   STATICLIBS= /home/dprice/pgplot/libpgplot.a /home/dprice/plot/libg2cmodified.a
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),mymac)
#  these are the settings for a Mac G4 running Panther 
#  using g95 with pgplot installed via fink
   F90C= g95
   F90FLAGS= -O3 -ffast-math
   DEBUGFLAG= -Wall -Wextra -Wno=165 -g -fbounds-check -ftrace=full
   PGPLOTLIBS= -L/sw/lib/pgplot -lpgplot -lg2c -L/sw/lib -lpng \
          -laquaterm -lcc_dynamic -Wl,-framework -Wl,Foundation
   SYSTEMFILE= system_f2003.f90
   PARALLEL= no
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM), gfortran_macosx)
#   gfortran with pgplot installed via fink
    F90C= gfortran
    F90FLAGS= -O3 -Wall
    PGPLOTLIBS= -L/sw/lib/pgplot -lpgplot -lg2c -L/sw/lib -lpng \
          -laquaterm # -lSystemStubs use this on OS/X Tiger
    SYSTEMFILE= system_unix.f90
    DBLFLAG= -fdefault-real-8
    DEBUGFLAG= -g -frange-check
    OMPFLAG= -fopenmp
    ENDIANFLAGBIG= -fconvert=big-endian
    ENDIANFLAGLITTLE= -fconvert=little-endian
    KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),myg95)
#  using the g95 compiler
   F90C= myg95
   F90FLAGS= -O3 -ffast-math
   X11LIBS= -L/usr/X11R6/lib64 -lX11
   PGPLOTLIBS = -L/usr/local64/pgplot -lpgplot -lpng -lg2c
   SYSTEMFILE= system_f2003.f90 # this is for Fortran 2003 compatible compilers
   ENDIANFLAGBIG= -fendian='BIG'
   ENDIANFLAGLITTLE= -fendian='LITTLE'
   PARALLEL= no
   KNOWN_SYSTEM=yes
endif

ifeq ($(SYSTEM),maccluster)
#  using the g95 compiler on the iMac cluster in Exeter
   ifeq ($(MACHTYPE),i386)
      F90C= myg95
      EXT= _i386
   else
      F90C= g95
      EXT= _ppc
   endif
   F90FLAGS= -O3 -ffast-math -Wall -Wextra -Wno=165 
   X11LIBS= -L/usr/X11R6/lib -lX11
   PGPLOTLIBS= -lSystemStubs
   STATICLIBS= /AstroUsers/djp212/pgplot/libpgplot.a
   SYSTEMFILE= system_f2003.f90 # this is for Fortran 2003 compatible compilers
   ENDIANFLAGBIG= -fendian='BIG'
   ENDIANFLAGLITTLE= -fendian='LITTLE'
   DEBUGFLAG=-fbounds-check -ftrace=full
   PARALLEL= no
   KNOWN_SYSTEM=yes
endif

#
# these are the flags used for linking
#
LDFLAGS= $(X11LIBS) $(PGPLOTLIBS)

#
# this is an option to change the endian-ness at compile time
# (provided the appropriate flags are specified for the compiler)
#
ifeq ($(ENDIAN), BIG)
    F90FLAGS += ${ENDIANFLAGBIG}
endif

ifeq ($(ENDIAN), LITTLE)
    F90FLAGS += ${ENDIANFLAGLITTLE}
endif

ifeq ($(PARALLEL),yes)
    F90FLAGS += $(OMPFLAGS)
endif

ifeq ($(DEBUG),yes)
    F90FLAGS += $(DEBUGFLAG)
endif

# Fortran flags same as F90
FC = $(F90C)
FFLAGS = $(F90FLAGS)

# define the implicit rule to make a .o file from a .f90/.f95 file
# (some Make versions don't know this)

%.o : %.f
	$(FC) $(FFLAGS) -c $< -o $@
%.o : %.f90
	$(F90C) $(F90FLAGS) -c $< -o $@
%.o : %.f95
	$(F90C) $(F90FLAGS) -c $< -o $@

#
# use either the parallel or serial versions of some routines
#
ifeq ($(PARALLEL),yes)
   INTERPROUTINES= interpolate3D_projection_P.f90
else
   INTERPROUTINES= interpolate3D_projection.f90
endif

# modules must be compiled in the correct order to check interfaces
# really should include all dependencies but I am lazy

SOURCESF90= globaldata.f90 transform.f90 \
         prompting.f90 geometry.f90 \
         colours.f90 colourparts.f90 units.f90 \
         exact_fromfile.f90 exact_mhdshock.f90 \
         exact_polytrope.f90 exact_rhoh.f90 \
         exact_sedov.f90 exact_shock.f90 exact_wave.f90 \
         exact_toystar1D.f90 exact_toystar2D.f90 \
         exact_densityprofiles.f90 exact_torus.f90 \
         limits.f90 options_limits.f90 \
         exact.f90 options_page.f90 \
         options_particleplots.f90 \
         allocate.f90 titles.f90 \
         calc_quantities.f90 get_data.f90\
         options_data.f90 \
	 options_powerspec.f90 options_render.f90 \
	 options_vecplot.f90 options_xsecrotate.f90 \
         rotate.f90 interpolate1D.f90 \
         interpolate2D.f90 interpolate3D_xsec.f90 \
         $(INTERPROUTINES) \
         interpolate3D_opacity.f90\
         interactive.f90 \
         fieldlines.f90 legends.f90 particleplot.f90 \
         powerspectrums.f90 render.f90 setpage.f90 \
         plotstep.f90 timestepping.f90 \
         defaults.f90 menu.f90 \
         $(SYSTEMFILE) splash.f90

# these are `external' f77 subroutines
SOURCESF=

OBJECTS = $(SOURCESF:.f=.o) $(SOURCESF90:.f90=.o) $(STATICLIBS)

#
# Now compile with the appropriate data read file
# (move yours to the top so that you can simply type "make")
#
ascii: checksystem $(OBJECTS) read_data_ascii.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o asplash $(OBJECTS) read_data_ascii.o

mbatesph: checksystem $(OBJECTS) read_data_mbate.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o bsplash $(OBJECTS) read_data_mbate.o

gadget: checksystem $(OBJECTS) read_data_gadget.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o gsplash $(OBJECTS) read_data_gadget.o

vine: checksystem $(OBJECTS) read_data_VINE.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o vsplash $(OBJECTS) read_data_vine.o

ndspmhd: checksystem $(OBJECTS) read_data_dansph.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o splash $(OBJECTS) read_data_dansph.o

dansph: checksystem $(OBJECTS) read_data_dansph_old.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o dsplash $(OBJECTS) read_data_dansph_old.o

scwsph: checksystem $(OBJECTS) read_data_scw.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o wsplash $(OBJECTS) read_data_scw.o

srosph: checksystem $(OBJECTS) read_data_sro.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o rsplash $(OBJECTS) read_data_sro.o 

spyros: checksystem $(OBJECTS) read_data_spyros.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o ssplash $(OBJECTS) read_data_spyros.o

sphNG: checksystem $(OBJECTS) read_data_sphNG.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o ssplash$(EXT) $(OBJECTS) read_data_sphNG.o
#--build universal binary on mac cluster
   ifeq ($(SYSTEM), maccluster)
	lipo -create ssplash_ppc ssplash_i386 -output ssplash || cp ssplash$(EXT) ssplash
   endif

RSPH: rsph

rsph: checksystem $(OBJECTS) read_data_rsph.o
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o rsplash $(OBJECTS) read_data_rsph.o

all: ndspmhd dansph sphNG srosph gadget mbatesph ascii

checksystem:
   ifeq ($(KNOWN_SYSTEM), yes)
	@echo ""
	@echo "Compiling splash for $(SYSTEM) system..........."
	@echo ""
        ifeq ($(ENDIAN), BIG)
	     @echo "Flags set for conversion to BIG endian"
        endif
        ifeq ($(ENDIAN), LITTLE)
	     @echo "Flags set for conversion to LITTLE endian"
        endif
        ifeq ($(PARALLEL), yes)
	     @echo "Compiling the PARALLEL code"
        else
	     @echo "Compiling the SERIAL code"
        endif
   else
	@echo ""
	@echo " Makefile for splash by Daniel Price "
	@echo " -- see INSTALL file for detailed instructions"
	@echo ""
	@echo " make: ERROR: value of SYSTEM = $(SYSTEM) not recognised..."
	@echo " =>set the environment variable SYSTEM to one listed "
	@echo "   in the Makefile and try again"
	@echo ""
	quit
   endif

## other stuff

doc:
	cd docs; latex splash; latex splash; dvips splash -o splash.ps; ps2pdf13 splash.ps

tar:
	tar cf splash.tar Makefile $(SOURCESF90) $(SOURCESF) read_data*.f90

targz:
	tar cf splash.tar Makefile $(SOURCESF90) $(SOURCESF) read_data*.f90
	gzip splash.tar

## unit tests of various modules as I write them

tests: test1 test2 test3

test1: interpolate3D_projection.o interpolate3D_xsec.o ./tests/test_interpolate3D.o 
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o test_interpolation3D ./tests/test_interpolate3D.o interpolate3D_projection.o interpolate3D_xsec.o
test2: transform.o ./tests/test_transform.o 
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o test_transform ./tests/test_transform.o transform.o
test3: fieldlines.o ./tests/test_fieldlines.o 
	$(F90C) $(F90FLAGS) $(LDFLAGS) -o test_fieldlines ./tests/test_fieldlines.o fieldlines.o

clean:
	rm *.o *.mod
