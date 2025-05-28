@echo on
mkdir build
cd build

cmake %CMAKE_ARGS% .. ^
  -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBOX2D_BUILD_UNIT_TESTS=OFF ^
  -DBOX2D_BUILD_TESTBED=OFF

cmake --build . --config Release --target install