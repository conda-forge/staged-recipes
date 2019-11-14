export PETSC_DIR=${PREFIX}
cp -r ../python/damask ${STDLIB_DIR}
mkdir build
cd build 
cmake -DDAMASK_SOLVER="SPECTRAL" ..
make install
