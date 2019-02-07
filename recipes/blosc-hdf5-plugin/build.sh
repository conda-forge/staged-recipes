mkdir build
cd build
H5_PLUGIN_PATH="${PREFIX}/lib/hdf5/plugin"
CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DPLUGIN_INSTALL_PATH=${H5_PLUGIN_PATH}"
cmake ${CMAKE_FLAGS} ../src 
make
make install 

