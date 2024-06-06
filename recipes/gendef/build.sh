
if [[ "$target_platform" == "win-64" ]]; then
  export host_alias=x86_64-w64-mingw32
  INSTALL_PREFIX=${PREFIX}/Library
else
  INSTALL_PREFIX=${PREFIX}
fi

# libmangle can only be built as a static
# library and is used only in the gendef executable
# We install it to a throwaway prefix
cd $SRC_DIR/mingw-w64-libraries/libmangle
./configure \
  --prefix=${SRC_DIR}/install
make -j${CPU_COUNT}
make install

cd $SRC_DIR/mingw-w64-tools/gendef
./configure \
  --with-mangle=${SRC_DIR}/install \
  --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
