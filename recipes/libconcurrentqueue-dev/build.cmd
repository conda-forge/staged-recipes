@echo on
cd /d "%SRC_DIR%"

mkdir build
cd build

cmake .. ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -G "Ninja"

cmake --build . --config Release
cmake --install .
