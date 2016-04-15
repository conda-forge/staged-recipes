#!/bin/bash

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  if [ $ARCH -eq 64 ]; then
    VL_ARCH="glnxa64"
  else
    VL_ARCH="glnx86"
  fi
  DYNAMIC_EXT="so"
  OPENMP=1
fi
if [ "$(uname -s)" == "Darwin" ]; then
  VL_ARCH="maci64"
  DYNAMIC_EXT="dylib"
  OPENMP=0
fi

# Turn off all intrinsics.
make ARCH=${VL_ARCH} DISABLE_AVX=yes DISABLE_OPENMP=$OPENMP MKOCTFILE="" MEX="" VERB=1

# Run tests
./bin/${VL_ARCH}/test_gauss_elimination
./bin/${VL_ARCH}/test_getopt_long
./bin/${VL_ARCH}/test_gmm
./bin/${VL_ARCH}/test_heap-def
./bin/${VL_ARCH}/test_host
./bin/${VL_ARCH}/test_imopv
./bin/${VL_ARCH}/test_kmeans
./bin/${VL_ARCH}/test_liop
./bin/${VL_ARCH}/test_mathop
./bin/${VL_ARCH}/test_mathop_abs
./bin/${VL_ARCH}/test_nan
./bin/${VL_ARCH}/test_qsort-def
./bin/${VL_ARCH}/test_rand
./bin/${VL_ARCH}/test_sqrti
./bin/${VL_ARCH}/test_stringop
./bin/${VL_ARCH}/test_svd2
./bin/${VL_ARCH}/test_threads
./bin/${VL_ARCH}/test_vec_comp

# Copy all the files and executables
mkdir -p $PREFIX/bin
cp bin/${VL_ARCH}/sift $PREFIX/bin/sift
cp bin/${VL_ARCH}/mser $PREFIX/bin/mser
cp bin/${VL_ARCH}/aib $PREFIX/bin/aib

mkdir -p $PREFIX/lib
cp bin/${VL_ARCH}/libvl.${DYNAMIC_EXT} $PREFIX/lib/libvl.${DYNAMIC_EXT}
mkdir -p $PREFIX/include/vl
cp vl/*.h $PREFIX/include/vl/

# For some reason the instal_name_tool fails, so I do it manually here
if [ "$(uname -s)" == "Darwin" ]; then
  install_name_tool -change @loader_path/libvl.dylib @rpath/../lib/libvl.dylib $PREFIX/bin/sift
  install_name_tool -change @loader_path/libvl.dylib @rpath/../lib/libvl.dylib $PREFIX/bin/mser
  install_name_tool -change @loader_path/libvl.dylib @rpath/../lib/libvl.dylib $PREFIX/bin/aib
fi
