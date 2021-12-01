#!/usr/bin/env bash
set -ex

if [[ "$target_platform" == osx* ]]; then
    CXXFLAGS="$CXXFLAGS -fno-common"
    CXXFLAGS="$CXXFLAGS -std=c++17"
    # macOS does not support std::uncaught_exceptions() before 10.12
    CXXFLAGS="$CXXFLAGS -DCATCH_CONFIG_NO_CPP17_UNCAUGHT_EXCEPTIONS"
    # re-enable mem_fun_ref in macOS when building with C++17 (used by dependency PPL.)
    CXXFLAGS="$CXXFLAGS -D_LIBCPP_ENABLE_CXX17_REMOVED_BINDERS"
fi

if [[ "$target_platform" == win* ]]; then
    cp $PREFIX/lib/gmp.lib $PREFIX/lib/gmpxx.lib
    CXXFLAGS="$CXXFLAGS -std=c++17"
fi

cd libflatsurf

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

./configure --prefix="$PREFIX" --without-benchmark --without-eantic --without-exactreal --without-byexample --without-version-script || (cat config.log; false)
[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
make install

if [[ "$target_platform" == win* ]]; then
    rm $PREFIX/lib/gmpxx.lib
fi
