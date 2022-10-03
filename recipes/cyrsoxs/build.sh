tar -zxvf V1.1.4.0.tar.gz
cd cyrsoxs-1.1.4.0/
mkdir build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release 
make
make install
cd ../
mkdir build-pybind
cd build-pybind
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DPYBIND=Yes -DUSE_SUBMODULE_PYBIND=No
make
make install
