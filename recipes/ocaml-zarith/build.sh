./configure
make -j1
make install
if [[ "$target_platform" == osx-* ]]; then
  make tests -k || true
  $INSTALL_NAME_TOOL -add_rpath $PREFIX/lib tests/zq.exe
  $INSTALL_NAME_TOOL -add_rpath $PREFIX/lib tests/pi.exe
  $INSTALL_NAME_TOOL -add_rpath $PREFIX/lib tests/tofloat.exe
  $INSTALL_NAME_TOOL -add_rpath $PREFIX/lib tests/ofstring.exe
fi
make tests
