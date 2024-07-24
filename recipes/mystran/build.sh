cmake -B build -S . \
      -D CMAKE_BUILD_TYPE="Release" \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX

make -C build install
mkdir -p $PREFIX/bin
cp $SRC_DIR/Binaries/mystran $PREFIX/bin/mystran