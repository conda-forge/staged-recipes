#!/usr/bin/env bash

set -e

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

export BUILD_FORTRAN=1
export BUILD_JPEG=1
export CTEST_EXTRA_FLAGS=""
export EXTRA_TESTS=1
if [[ $HOST =~ darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export FFLAGS="-isysroot $CONDA_BUILD_SYSROOT $FFLAGS"
  export REPLACE_TPL_ABSOLUTE_PATHS=1
  if [[ $HOST =~ arm64 ]]; then
    export MACOS_LE_FLAG="-D IEEE_LE=1"
    export BUILD_FORTRAN=0
  fi
elif [[ $HOST =~ linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
  export REPLACE_TPL_ABSOLUTE_PATHS=1
  if [[ $HOST =~ powerpc64le ]]; then
    # failure in test 'eccodes_t_grib_packing_order' related to jpeg packing
    # failure in eccodes_t_grib_ieee so disable by disabling the extra tests on this platform
    export BUILD_JPEG=0
    export EXTRA_TESTS=0
    export CTEST_EXTRA_FLAGS="-E eccodes_t_grib_packing_order"
  fi
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir ../build && cd ../build

# One can use the following cmake flag to get more verbose debugging info
# -D ECBUILD_LOG_LEVEL=DEBUG

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_FIND_FRAMEWORK=LAST \
      -D INSTALL_LIB_DIR='lib' \
      -D ENABLE_JPG=$BUILD_JPEG \
      -D ENABLE_NETCDF=1 \
      -D ENABLE_PNG=1 \
      -D ENABLE_PYTHON=0 \
      -D ENABLE_FORTRAN=$BUILD_FORTRAN \
      -D ENABLE_ECCODES_THREADS=1 \
      -D ENABLE_AEC=1 \
      -D ENABLE_EXTRA_TESTS=$EXTRA_TESTS \
      -D ECBUILD_DOWNLOAD_TIMEOUT=60 \
      -D REPLACE_TPL_ABSOLUTE_PATHS=$REPLACE_TPL_ABSOLUTE_PATHS \
      -D CMAKE_FIND_ROOT_PATH=$PREFIX \
      -D CMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
      -D CMAKE_PROGRAM_PATH=$BUILD_PREFIX \
      $MACOS_LE_FLAG \
      $SRC_DIR

make -j $CPU_COUNT VERBOSE=1
export ECCODES_TEST_VERBOSE_OUTPUT=1
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
ctest --output-on-failure -j $CPU_COUNT $CTEST_EXTRA_FLAGS
fi

make install
