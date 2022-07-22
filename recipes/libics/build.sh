set -euxo pipefail

mkdir -p _build
cd _build

cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DBUILD_SHARED_LIBS=On

make -j${CPU_COUNT} install

# Better location for cmake modules
mkdir -p "$PREFIX/share/cmake/libics"
mv $PREFIX/cmake/libics*.cmake $PREFIX/share/cmake/libics/
