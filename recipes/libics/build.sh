set -euxo pipefail

mkdir -p _build
cd _build

cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DBUILD_SHARED_LIBS=On

make -j${CPU_COUNT} install
