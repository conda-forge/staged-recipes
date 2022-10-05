
mkdir build
cd build
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release 
make install
cd ../

mkdir build-pybind
cd build-pybind
cmake ${SRC_DIR} ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DPYBIND=Yes -DUSE_SUBMODULE_PYBIND=No -DPython_EXECUTABLE="$PYTHON"  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  ${CMAKE_PLATFORM_FLAGS[@]} -DCMAKE_CUDA_RUNTIME_LIBRARY=Shared
make install
