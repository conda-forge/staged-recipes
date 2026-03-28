#!/bin/bash

# Create Makefile.arch in the source directory with your configuration
cat > Makefile.arch << EOF
# Fortran compilers
FC = gfortran
MPIFORT = mpif90

# Compiler flags
OPTIONS = -O2 -DBLAS -DMPI -D__OLD_MPI -cpp -fallow-argument-mismatch -ffree-line-length-512 -D__FFTW3

# Linear algebra libraries
BLAS = -L${PREFIX}/lib -lblas -L${PREFIX}/lib -lscalapack

# FFTW flags
FFTWI = -I${PREFIX}/include
FFTWL = -L${PREFIX}/lib -lfftw3

# Install directory (used by Makefile install target)
INSTDIR = ${PREFIX}/bin


# ESPRESSO_DIR =${PREFIX}/bin/


PW_EXE = ${PREFIX}/bin/pw.x
PP_EXE = ${PREFIX}/bin/pp.x
PH_EXE = ${PREFIX}/bin/ph.x

ONCVPSP_DIR =/home/a.geondzhian/src/oncvpsp/
EOF

# Run make with MPI compiler (mpif90) and environment variables
make clean
# make FC=${MPIFORT} OPTIONS="${OPTIONS}" BLAS="${BLAS}" FFTWL="${FFTWL}" FFTWI="${FFTWI}" INSTDIR="${INSTDIR}"
make

# Install binaries to install prefix
make install PREFIX=${PREFIX}
