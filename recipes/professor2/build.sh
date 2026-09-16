#!/usr/bin/env bash
set -euxo pipefail

# Get an updated config.sub and config.guess
cp "${BUILD_PREFIX}"/share/gnuconfig/config.* .

# Eigen >=5 needs C++14 or later. The default in configure is c++11.
export CXXSTD="c++17"
export PYTHON="${PYTHON}"

./configure --help
./configure --prefix="${PREFIX}" --with-eigen="${PREFIX}"

make lib -j"${CPU_COUNT}"

# The Makefile's "make lib" ignores LDFLAGS, so add the conda rpath here.
# Without an explicit install_name the dylib's ID is the relative link path
# "lib/libProfessor2.dylib", which is what dependents then fail to dlopen.
if [[ "${target_platform}" == osx-* ]]; then
  LDFLAGS="${LDFLAGS} -Wl,-install_name,@rpath/libProfessor2${SHLIB_EXT}"
fi
rm -f lib/libProfessor2.so
"${CXX}" -shared ${LDFLAGS} -o lib/libProfessor2${SHLIB_EXT} obj/*.o

# Build the Cython bindings directly rather than via "make pyext", which runs
# pip in build isolation and would try to download setuptools.
cython --cplus pyext/professor2/core.pyx
cd pyext
PROF_VERSION="${PKG_VERSION}" PROF_ROOT="${SRC_DIR}" \
  "${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
cd ..

# Manual install instead of "make install", which also drops contrib/ and
# jupyter/ directly into ${PREFIX}.
mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include" "${PREFIX}/share/professor2"
cp bin/prof2-* "${PREFIX}/bin/"
# Point the script shebangs at the environment's python for relocatability.
sed -i "1s|^#! */usr/bin/env python\$|#!${PREFIX}/bin/python|" "${PREFIX}"/bin/prof2-*
cp lib/libProfessor2${SHLIB_EXT} "${PREFIX}/lib/"
cp -r include/Professor "${PREFIX}/include/"
cp -r contrib jupyter "${PREFIX}/share/professor2/"
