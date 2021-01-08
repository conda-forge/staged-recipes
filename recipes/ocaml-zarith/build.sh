./configure
make -j1
make install
if [[ "$target_platform" == osx-* ]]; then
  make tests || true
  $INSTALL_NAME_TOOL -add_rpath $PREFIX/lib tests/zq.exe
fi
make tests
