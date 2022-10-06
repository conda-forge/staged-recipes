set -ex

export ARCH="x86_64"
export LIBDIRS="${PREFIX}/lib"
export BLAS_LIBS="-lblas"
export LAPACK_LIBS="-llapack"
export FFT_LIBS="-lfftw3"
# Override C and Fortran preprocessor
export CPP="${CC} -E -P"
export FPP="${FC} -E -P -cpp"
#export CPPFLAGS="${CPPFLAGS}"
export CC="mpicc"
export CFLAGS="${CFLAGS} -L${PREFIX}/lib"
export FC="mpif90"
export FFLAGS="${FFLAGS} -fallow-argument-mismatch -L${PREFIX}/lib"
export LD="mpif90"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure \
    --prefix=${PREFIX}

make kcp
export OMPI_MCA_plm_rsh_agent=sh
make check
make install
