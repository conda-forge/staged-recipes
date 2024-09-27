@echo on

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% ..
make -j%NUMBER_OF_PROCESSORS%
make install
