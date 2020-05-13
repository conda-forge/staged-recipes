set -ex

# Make it easier to detect java on windows
if [ "$target_platform" == "win-64" ]; then
  export CFLAGS="${CFLAGS} -I${PREFIX}/include/win32"
fi

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

if [ "$target_platform" == "win-64" ]; then
  patch_libtool
fi
make -j${CPU_COUNT}

make install
