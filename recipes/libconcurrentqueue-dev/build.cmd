@echo on

cd /d "%SRC_DIR%"

mkdir build
cd build

cmake .. ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release

cmake --build . --config Release
cmake --install .
