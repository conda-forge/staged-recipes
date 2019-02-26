./configure --prefix $PREFIX 
make
make install

# run test binary 
# note this seems not to work in meta.yaml test section due to some linking problems
./sample/sample > /dev/null
