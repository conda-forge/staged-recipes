set -ex

# Make it easier to detect java on windows
if [ "$target_platform" == "win-64" ]; then
  export CFLAGS="${CFLAGS} -I${PREFIX}/include/win32"
fi

# Make sure we don't use an old Makefile
rm -f Makefile

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

if [ "$target_platform" == "win-64" ]; then
  patch_libtool
  # Windows doesn't do well with parallel builds???
  make VERBOSE=1 V=1
else
  make -j${CPU_COUNT}
fi

make install
