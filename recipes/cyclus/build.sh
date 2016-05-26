#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export LIBRARY_PATH="${PREFIX}/lib:${LIBRARY_PATH}"
export INCLUDE_PATH="${PREFIX}/include:${INCLUDE_PATH}"

export PATH="${PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export CMAKE_LIBRARY_PATH="${PREFIX}/lib:${CMAKE_LIBRARY_PATH}"

if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  export CC=gcc
  export CXX=g++
  #export CC=clang
  #export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  #export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export CXXFLAGS="${CXXFLAGS} -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  #export LDFLAGS="${LDFLAGS} -stdlib=libc++ -lc++"
  export LDFLAGS="${LDFLAGS} -std=c++11 -lc++"
  export LINKFLAGS="${LDFLAGS}"
  export CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"

  export CFLAGS="${CFLAGS} -m${ARCH} -arch i386"
  export CXXFLAGS="${CXXFLAGS} -m${ARCH} -arch i386"
else
  # for Linux
  export CXXFLAGS="${CXXFLAGS} -DBOOST_MATH_DISABLE_FLOAT128"
  export CC=
  export CXX=

  export CFLAGS="${CFLAGS} -m${ARCH}"
  export CXXFLAGS="${CXXFLAGS} -m${ARCH}"
fi

#
# Build and install
#
export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --coin_root="${PREFIX}" \
  --boost_root="${PREFIX}" \
  --hdf5_root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  --clean

#
# Run tests
#
cd tests
${PREFIX}/bin/cyclus_unit_tests
nosetests cycpp_tests.py
nosetests test_include_recipe.py  test_lotka_volterra.py
nosetests test_null_sink.py  test_source_to_sink.py
nosetests test_trivial_cycle.py test_inventories.py
nosetests test_minimal_cycle.py test_smbchk.py
cd ..
