:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
