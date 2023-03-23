rmdir /s /q build
mkdir build
cd build

# MSGPACK_CXX20 does not force all consumer libraries to use C++20,
# it just uses C++20 to compile the test suite so all tests are compiled
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DMSGPACK_CXX20:BOOL=ON ^
    -DMSGPACK_BUILD_TESTS:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1
