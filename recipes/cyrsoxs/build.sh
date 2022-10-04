export VERBOSE=1
mkdir build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release 
make install
cd ../
mkdir build-pybind
cd build-pybind
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DPYBIND=Yes -DUSE_SUBMODULE_PYBIND=No -DPython_EXECUTABLE="$PYTHON" 
make install VERBOSE=1
