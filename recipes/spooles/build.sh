make lib
cd MT/src/
make


mkdir -p $PREFIX/spooles/include
mkdir -p $PREFIX/lib

cp $SRC_DIR/*.h $PREFIX/spooles/include/
cp *.a $PREFIX/lib/