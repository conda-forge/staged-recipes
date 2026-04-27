#!/bin/bash
set -euo pipefail

# ipbus Makefiles use CACTUS_OS=el7|el8|…; set the major version from conda-forge $BUILD (e.g. conda_el9 → el9), else el8.
if [[ "${BUILD:-}" =~ conda_(el|cos|alma)([0-9]+) ]]; then
  CACTUS_OS="el${BASH_REMATCH[2]}"
else
  CACTUS_OS=el8
fi

# mfCommonDefs.mk sets CXX=g++ so we must pass CXX= here
make -j${CPU_COUNT:-1} prefix=$PREFIX \
    CACTUS_OS="$CACTUS_OS" \
    Set=uhal \
    CXX="$CXX" \
    BUILD_UHAL_GUI=0 \
    EXTERN_BOOST_INCLUDE_PREFIX=$PREFIX/include \
    EXTERN_BOOST_LIB_PREFIX=$PREFIX/lib \
    EXTERN_PUGIXML_INCLUDE_PREFIX=$PREFIX/include \
    EXTERN_PUGIXML_LIB_PREFIX=$PREFIX/lib \
    EXTERN_PYBIND11_INCLUDE_PREFIX=$PREFIX/include \
    build
make prefix=$PREFIX Set=uhal install

# We cannot remove test .so files because the python package links against them
rm -rf "$PREFIX/bin/uhal/tests"
rm -rf "$PREFIX/include/uhal/tests"
rm -rf "$PREFIX/etc/uhal/tests"

mkdir -p "$PREFIX/share/ipbus"
mv "$PREFIX/etc/uhal/tools" "$PREFIX/share/ipbus/"
rmdir "$PREFIX/etc/uhal" 2>/dev/null || true

find "$PREFIX/bin/uhal/tools" -mindepth 1 -maxdepth 1 -exec ln -sf {} "$PREFIX/bin/" \;

