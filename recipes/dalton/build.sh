cd $SRC_DIR
./setup --type release --mpi --blas auto --lapack auto
cd build
make -j
mkdir -p $PREFIX/bin
cp -v dalton.x $PREFIX/bin
cp -v dalton $PREFIX/bin
cp -rv basis $PREFIX/bin

