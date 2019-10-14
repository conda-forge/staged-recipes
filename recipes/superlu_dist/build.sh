mkdir build; cd $_

export CFLAGS="$CFLAGS -std=c99"
export LDFLAGS="-L$PREFIX/lib -lmpi -lparmetis $LDFLAGS"

cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DTPL_PARMETIS_LIBRARIES="$BUILD_PREFIX/lib/libparmetis${SHLIB_EXT}" \
  -DTPL_PARMETIS_INCLUDE_DIRS="$BUILD_PREFIX/include" \
  -DBUILD_SHARED_LIBS="ON" \
  $SRC_DIR/SuperLU_DIST_5.1.3

make
make install
