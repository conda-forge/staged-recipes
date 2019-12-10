# fix libdb - https://github.com/conda-forge/libdb-feedstock/pull/7
cd deps
tar xvzf db-6.2.23.tar.gz
cp db-6.2.23/lang/cxx/stl/*.h ${PREFIX}/include
cp db-6.2.23/build_windows/*.h ${PREFIX}/include
cd ..

mkdir build
cd build
ln -s "${SP_DIR}"/liblammps.so "${PREFIX}"/lib/liblammps.so
cmake -DCMAKE_PREFIX_PATH="${PREFIX}"  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../ 
make -j${CPU_COUNT}
