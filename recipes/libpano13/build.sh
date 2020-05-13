set -ex
if [[ "$target_platform" == "win-64" ]]; then
  # export LDFAGS="${LDFLAGS} -L${PREFIX}/bin/libpng16.dll"
  # export LDLIBS="${LDLIBS} -lpng16"
  # export LIBS="${LIBS} -lpng16"
fi
./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME} \
    --with-png=${PREFIX}

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -j${CPU_COUNT}
make install
