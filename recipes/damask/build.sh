export PETSC_DIR=${PREFIX}
cmake
make spectral
make install
echo ${STDLIB_DIR}
cp -r python/damask ${STDLIB_DIR}
