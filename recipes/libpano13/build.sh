set -ex

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

if [ "$target_platform" == "win-64" ]; then
  patch_libtool
fi

make -j${CPU_COUNT}
make install
