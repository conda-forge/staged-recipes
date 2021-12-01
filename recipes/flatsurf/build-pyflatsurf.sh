#!/usr/bin/env bash
set -ex

if [[ "$target_platform" == osx* ]]; then
    CXXFLAGS="$CXXFLAGS -fno-common"
    CXXFLAGS="$CXXFLAGS -std=c++17"
fi

if [[ "$target_platform" == win* ]]; then
    cp $PREFIX/lib/gmp.lib $PREFIX/lib/gmpxx.lib
    CXXFLAGS="$CXXFLAGS -std=c++17"
fi

cd pyflatsurf

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure --prefix="$PREFIX" --without-sage --without-realalg --without-pytest || (cat config.log; false)
[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check || (cat test/test-suite.log; false)
fi
make install


