:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

rd /s /q build
mkdir build
cd build

set PKG_NAME_ALIAS=%PKG_NAME:-=_%

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DCMAKE_CXX_STANDARD=14 ^
    %SRC_DIR%\%PKG_NAME_ALIAS%
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
