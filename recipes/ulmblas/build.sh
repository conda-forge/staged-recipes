#! /bin/bash
#
#  conda-forge: build and install libulmblas (no LAPACK: conda-forge's
#  Netlib liblapack runs on top of it, as for BLIS).  The platform is the
#  target, also when cross compiling (osx-arm64 and linux-aarch64 are
#  cross compiled on conda-forge).
#
set -ex

case "$target_platform" in
    osx-arm64)     export ULMBLAS_PLATFORM=Darwin-arm64 ;;
    linux-64)      export ULMBLAS_PLATFORM=Linux-x86_64 ;;
    linux-aarch64) export ULMBLAS_PLATFORM=Linux-aarch64 ;;
    win-64)        export ULMBLAS_PLATFORM=MINGW64-x86_64 ;;
    *) echo "unsupported platform $target_platform"; exit 1 ;;
esac

#  conda's flags select a generic target (-march=nocona -mtune=haswell on
#  linux-64): the backends choose their own instruction sets
export CFLAGS=$(echo "$CFLAGS" | sed -e 's/-march=[^ ]*//g' -e 's/-mtune=[^ ]*//g')
export CXXFLAGS=$(echo "$CXXFLAGS" | sed -e 's/-march=[^ ]*//g' -e 's/-mtune=[^ ]*//g')

export MAKE="make -j${CPU_COUNT:-2}"
export FC=none
export ULMBLAS_INCLUDEDIR="$PREFIX/include/ulmblas"
if [ "$target_platform" = win-64 ]; then
    export ULMBLAS_INCLUDEDIR="$PREFIX/Library/include/ulmblas"
    sh interfaces/install-shared.sh "$PREFIX/Library"
else
    sh interfaces/install-shared.sh "$PREFIX"
fi
