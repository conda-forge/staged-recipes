mkdir build && cd build

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%

cmake -G "NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
