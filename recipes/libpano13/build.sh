set -ex

echo "exporting cflags"
# Make it easier to detect java on windows
if [ "$target_platform" == "win-64" ]; then
  export CFLAGS="${CFLAGS} -I${PREFIX}/include/win32"
fi
echo "exported  cflags"

# Make sure we don't use an old Makefile
rm -f Makefile Makefile.in
echo "removed makefiles"

automake
echo "ran automake"

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
