mkdir build
cd build
ln -s "${SP_DIR}"/liblammps.so "${PREFIX}"/lib/liblammps.so
cmake -DCMAKE_PREFIX_PATH="${PREFIX}"  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../ 
make -j${CPU_COUNT}
