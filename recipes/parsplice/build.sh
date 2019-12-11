# Hack while waiting for https://github.com/conda-forge/nauty-feedstock/pull/10
cd deps
tar xvzf nauty26r7.tar.gz
cp nauty26r7/*.h "${PREFIX}"/include/nauty
cd ..

mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH="${PREFIX}"  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../ 
make -j${CPU_COUNT}
