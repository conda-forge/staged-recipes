#
#  -- LAPACK95 interface driver routine (version 2.0) --
#     UNI-C, Denmark; Univ. of Tennessee, USA; NAG Ltd., UK
#     August 5, 2000
#
FC_fr	 = $(FC) -ffree-form
FC_ff    = $(FC) -ffixed-form
# -dcfuns  Enable recognition of non-standard double
#          precision  complex intrinsic functions
# -dusty   Allows the compilation and execution of "legacy"
#          software by downgrading the category  of  common
#          errors  found  in  such software from "Error" to
# -ieee=full enables all IEEE arithmetic facilities
#          including non-stop arithmetic.

OPTS0    = -pipe
MODLIB   = -I$(PREFIX)/include
OPTS1    = -c -O3 $(OPTS0)
OPTS3    = $(OPTS1) $(MODLIB)
OPTL     = -o 
OPTLIB   =

LAPACK_PATH = $(PREFIX)/lib

LAPACK95 = ../lapack95$(SHLIB_EXT)
LAPACK77 = $(LAPACK_PATH)/liblapack$(SHLIB_EXT)
BLAS     = $(LAPACK_PATH)/libblas$(SHLIB_EXT)

LIBS     = $(LAPACK77) $(BLAS)
SUF      = f90

.SUFFIXES: .f90 .f .o

.$(SUF).o: 
	$(FC_fr) $(OPTS3) $<

.f.o:
	$(FC_ff) $(OPTS3) $<
