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
else
    # Get an updated config.sub and config.guess
    cp $BUILD_PREFIX/share/gnuconfig/config.* .
fi

# This line can be dropped once the patches have been upstreamed.
autoreconf -ivf

./configure --prefix="$PREFIX" --without-benchmark || (cat config.log; false)

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check || (cat test/test-suite.log; false)
fi
make install

if [[ "$target_platform" == win* ]]; then
    rm $PREFIX/lib/gmpxx.lib
fi
