mkdir build && cd build

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D BUILD_STATIC_LIBS:BOOL=ON ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
