@echo on

md build
pushd build
cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -GNinja ..
ninja install
popd
