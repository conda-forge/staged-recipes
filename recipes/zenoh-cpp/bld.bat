cd .\install
rmdir /s /q build
mkdir build
cd build

% tests are disabled as of 0.11.0 they depend on zenohc's static library
% switch them on on 1.0.0 as they can be compiled against zenohc's shared library
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
