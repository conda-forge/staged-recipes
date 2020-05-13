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
  # export CFLAGS="${CFLAGS} -I${PREFIX}/include/gtk-3.0"
  make -D__WIN__=1 -j${CPU_COUNT}
else
  make -j${CPU_COUNT}
fi

make install
