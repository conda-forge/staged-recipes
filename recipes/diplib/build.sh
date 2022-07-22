set -euxo pipefail

mkdir -p _build
cd _build

# These flags below skip the compilation of vendored zlib and jpeg,
# which are only needed to compile other vendored deps we are patching out
# We disable them with flags to keep the patch simpler.
cmake ${CMAKE_ARGS} ${SRC_DIR} \
    -DDIP_ENABLE_ZLIB=OFF \
    -DDIP_ENABLE_JPEG=OFF

make -j${CPU_COUNT} install
make pip_install

exit 1