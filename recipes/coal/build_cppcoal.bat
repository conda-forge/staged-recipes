rm -rf build

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

cmake %SRC_DIR% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DPython_EXECUTABLE="%PYTHON%" ^
    -DBUILD_PYTHON_INTERFACE=OFF ^
    -DGENERATE_PYTHON_STUBS=OFF ^
    -DCOAL_HAS_QHULL=ON ^
    -DBUILD_TESTING=OFF
if errorlevel 1 exit 1

:: Build.
ninja
if errorlevel 1 exit 1

:: Install.
ninja install
if errorlevel 1 exit 1
