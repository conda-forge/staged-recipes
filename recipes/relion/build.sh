export CC=gcc
export CXX=g++

export OMPI_CC=mpicc
export OMPI_CXX=mpicxx

BUILD_DIRECTORY=${PREFIX}/build

mkdir ${PREFIX}/build && cd ${PREFIX}/build
cmake \
-DGUI=ON \
-DFORCE_OWN_FLTK=OFF \
-DFORCE_OWN_FFTW=OFF \
-DBUILD_SHARED_LIBS=ON \
$SRC_DIR
make -j $CPU_COUNT
