@ECHO ON

mkdir build
cd build

cmake -G "Ninja" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DWITH_TESTS=OFF ^
  -DWITH_PYTHON=OFF ^
  %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1
cmake --install . --config Release
if errorlevel 1 exit 1

cd %SRC_DIR%
%PYTHON% setup.py install
if errorlevel 1 exit 1
