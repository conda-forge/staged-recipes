make lib
cd MT/src/
make

mkdir -p $PREFIX/lib
cp *.a $PREFIX/lib/

cd ../..
cp *.a $PREFIX/lib/

mkdir -p $PREFIX/include/spooles
find . -name '*.h' -exec rsync -R {} $PREFIX/include/spooles \;