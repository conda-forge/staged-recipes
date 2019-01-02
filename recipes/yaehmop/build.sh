cd $SRC_DIR/tightbind
make
# Makefile can't do custom --prefix, do manual make install
mv bind eht_bind
mkdir -p $PREFIX/bin
cp eht_bind $PREFIX/bin
