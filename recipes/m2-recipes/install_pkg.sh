mkdir $PREFIX/Library
cp -R $SRC_DIR/binary-${PKG_NAME}/* $PREFIX/Library/

if [[ "${PKG_NAME}" == "m2-file" ]]; then
  rm -rf $PREFIX/Library/usr/lib/python3.11/site-packages/__pycache__/
fi

if [[ "${PKG_NAME}" != "m2-msys2-launcher" && "${PKG_NAME}" != "m2-base" ]]; then
  test -d $PREFIX/Library/usr
fi

