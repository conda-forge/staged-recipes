set -ex

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
make install
