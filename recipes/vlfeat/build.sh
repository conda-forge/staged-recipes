#!/bin/bash

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  if [ $ARCH -eq 64 ]; then
    VL_ARCH="glnxa64"
  else
    VL_ARCH="glnx86"
  fi
  DYNAMIC_EXT="so"
fi
if [ "$(uname -s)" == "Darwin" ]; then
  VL_ARCH="maci64"
  DYNAMIC_EXT="dylib"
fi

export CFLAGS="-I$PREFIX/include -DVL_DISABLE_AVX=1 -DVL_DISABLE_OPENMP=1 -DVL_DISABLE_THREADS=1"
export LDFLAGS="-L$PREFIX/lib"

# Turn off all intrinsics.
make ARCH=${VL_ARCH} DISABLE_AVX=yes DISABLE_THREADS=yes DISABLE_OPENMP=yes

# On OSX the resolution of the libvl.dylib doesn't seem to
# work properly for the executables - but they are properly
# relatively linked using @loader_path, therefore, copy
# the dylib into bin so they work properly.
if [ "$(uname -s)" == "Darwin" ]; then
  mkdir -p $PREFIX/bin/
  cp bin/${VL_ARCH}/libvl.${DYNAMIC_EXT} $PREFIX/bin/
fi

mkdir -p $PREFIX/bin
cp bin/${VL_ARCH}/sift $PREFIX/bin/
cp bin/${VL_ARCH}/mser $PREFIX/bin/
cp bin/${VL_ARCH}/aib $PREFIX/bin/

mkdir -p $LIBRARY_PATH
cp bin/${VL_ARCH}/libvl.${DYNAMIC_EXT} $LIBRARY_PATH/

mkdir -p $INCLUDE_PATH/vl
cp vl/*.h $INCLUDE_PATH/vl
