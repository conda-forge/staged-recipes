cd $SRC_DIR/tightbind
make
# manual make install essentially..
mv bind yaehmop
cp yaehmop $PREFIX/bin
