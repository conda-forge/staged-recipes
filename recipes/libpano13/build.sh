set -ex

# Make it easier to detect java on windows
if [ "$target_platform" == "win-64" ]; then
  export CFLAGS="${CFLAGS} -I${PREFIX}/include/win32"
fi

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

cat config.log
cat Makefile
if [ "$target_platform" == "win-64" ]; then
  patch_libtool
  # Windows doesn't do well with parallel builds???
  make VERBOSE=1 V=1
else
  make -j${CPU_COUNT}
fi

make install
