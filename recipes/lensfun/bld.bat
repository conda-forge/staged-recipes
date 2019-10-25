mkdir build && cd build

set CMAKE_CONFIG="Release"
set PKG_CONFIG_PATH=%PREFIX%/lib/pkgconfig
set LD_LIBRARY_PATH=%PREFIX%/lib

cmake -G"NMake Makefiles"                       ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"    ^
      -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"       ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
