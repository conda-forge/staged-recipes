mkdir build-lib
cd build-lib

cmake -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -Dfilepattern_SHARED_LIB=ON  -DRUN_GTEST=OFF ..

if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1