
mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"  -DBUILD_PYTHON_INTERFACE=ON -G "Ninja" ..
ninja
ninja install
popd
