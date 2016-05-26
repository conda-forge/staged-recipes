#!/usr/bin/env bash
set -e

UNAME="$(uname)"
SRC_ROOT="$(pwd)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"

export LD_LIBRARY_PATH="${PREFIX}/lib"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib"
export PATH="${PREFIX}/bin:${PATH}"


if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  LIBEXT=".dylib"
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -lc++"
  export LINKFLAGS="${LDFLAGS}"
else
  # for Linux
  LIBEXT=".so"
  export CC=
  export CXX=
  #export CXXFLAGS="${CXXFLAGS} -std=c++11"
  #export LDFLAGS="${LDFLAGS} -std=c++11"
fi

# make code
#mkdir -p build
#cd build
#which python
#cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
#  -DCMAKE_BUILD_TYPE=Release \
#  -DHDF5_ROOT="${PREFIX}" \
#  -DCOIN_ROOT_DIR="${PREFIX}" \
#  -DBOOST_ROOT="${PREFIX}" \
#  -DLAPACK_LIBRARIES="${PREFIX}/lib/libopenblas${LIBEXT}" \
#  -DBLAS_LIBRARIES="${PREFIX}/lib/libopenblas${LIBEXT}" \
#  "${SRC_ROOT}"
#make
#make install

${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --coin_root="${PREFIX}" \
  --boost_root="${PREFIX}" \
  --hdf5_root="${PREFIX}" \
  --clean
#  -DLAPACK_LIBRARIES="${PREFIX}/lib/libopenblas${LIBEXT}" \
#  -DBLAS_LIBRARIES="${PREFIX}/lib/libopenblas${LIBEXT}" \
