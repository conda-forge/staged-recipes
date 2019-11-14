export PETSC_DIR=${PREFIX}
mkdir build
cd build 
cmake ..
make spectral
make install
echo ${STDLIB_DIR}
cp -r ..python/damask ${STDLIB_DIR}
