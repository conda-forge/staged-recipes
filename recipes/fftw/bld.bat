
@rem See https://github.com/xantares/fftw-cmake/
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
cp "%RECIPE_DIR%\config.h.in" .
if errorlevel 1 exit 1

mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                             ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"                      ^
  -DENABLE_THREADS=ON                                      ^
  -DWITH_COMBINED_THREADS=ON                               ^
  -DENABLE_SSE2=ON                                         ^
  -DENABLE_AVX=ON                                          ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100
if errorlevel 1 exit 1

del CMakeCache.txt

cmake -LAH -G"NMake Makefiles"                             ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"                      ^
  -DENABLE_THREADS=ON                                      ^
  -DWITH_COMBINED_THREADS=ON                               ^
  -DENABLE_SSE2=ON                                         ^
  -DENABLE_AVX=ON                                          ^
  -DENABLE_FLOAT=ON                                        ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100
if errorlevel 1 exit 1

