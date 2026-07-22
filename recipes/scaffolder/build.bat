@echo off

set BUILD_DIR=build

if not exist %BUILD_DIR% ( mkdir %BUILD_DIR% )
cd %BUILD_DIR%

cmake -GNinja ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_PYSCAFFOLDER=OFF ^
  -DVERSION=%SCAFFOLDER_VERSION% ^
  ../

cmake --build . --config Release
cmake --install .