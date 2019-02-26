./configure --prefix $PREFIX 
make
make install

mkdir -p $PREFIX/bin
cp sample/sample $PREFIX/bin

# run test binary 
# note this seems not to work in meta.yaml test section due to some linking problems
./sample/sample > /dev/null
