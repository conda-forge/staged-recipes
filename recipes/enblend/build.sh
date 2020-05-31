set -ex

mkdir build
cd build

# vigra headers use std::bind1st, which is deprecated in clang9
if [[ ${target_platform} =~ osx-64.* ]]; then
    export CXXFLAGS="${CXXFLAGS-} -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES -Wno-register"
fi

# Use of clock_gettime requires librt on platforms with glibc < v2.17
if [[ ${target_platform} =~ .*linux.* ]]; then
    export LDFLAGS="-lrt -Wl,--as-needed"
fi

cmake \
    -DCMAKE_BUILD_TYPE="Release"                                          \
    -DCMAKE_PREFIX_PATH=${PREFIX}                                         \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                                      \
    ..

make -j${CPU_COUNT}
make install
