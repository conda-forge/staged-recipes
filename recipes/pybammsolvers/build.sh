set -euxo pipefail

### Compile and install SUITESPARSE ###
# SuiteSparse is required to compile SUNDIALS's
# KLU solver.

SUITESPARSE_DIR=suitesparse
for dir in SuiteSparse_config AMD COLAMD BTF KLU
do
    make -C $SUITESPARSE_DIR/$dir library
    make -C $SUITESPARSE_DIR/$dir install INSTALL=/usr
done

mkdir -p build_sundials
cd build_sundials
KLU_INCLUDE_DIR=/usr/local/include
KLU_LIBRARY_DIR=/usr/local/lib
SUNDIALS_DIR=sundials
cmake -DENABLE_LAPACK=ON\
      -DSUNDIALS_INDEX_SIZE=32\
      -DEXAMPLES_ENABLE:BOOL=OFF\
      -DENABLE_KLU=ON\
      -DENABLE_OPENMP=ON\
      -DKLU_INCLUDE_DIR=$KLU_INCLUDE_DIR\
      -DKLU_LIBRARY_DIR=$KLU_LIBRARY_DIR\
      -DCMAKE_INSTALL_PREFIX=/usr\
      ../$SUNDIALS_DIR
make install
