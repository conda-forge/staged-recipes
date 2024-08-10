rmdir /s /q build
mkdir build
cd build

:: Only GENERIC Target is supported on MSVC
:: See https://github.com/giaf/blasfeo/blob/b6bc34c6cb1995aea60968403016110bd3288e3b/CMakeLists.txt#L255
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DTARGET=GENERIC ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
if errorlevel 1 exit 1
ctest --output-on-failure -C Release
