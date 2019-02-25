./configure --prefix $PREFIX 
make
make install

mkdir -p $PREFIX/bin
cp sample/sample $PREFIX/bin
