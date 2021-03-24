mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/share
ls -lha
cp bin/* $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
cp -r share/* $PREFIX/share/
