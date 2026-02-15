mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DOpenMP_RUNTIME_MSVC="llvm" ^
    -DBUILD_tests=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    ..
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

cmake --build . --config Release -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit %ERRORLEVEL%

cmake --install . --config Release
if %ERRORLEVEL% neq 0 exit %ERRORLEVEL%
