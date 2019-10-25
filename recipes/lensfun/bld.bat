mkdir build && cd build

set CMAKE_CONFIG="Release"
set INCLUDE=%PREFIX%\Library\include\regex
set LIB=%PREFIX%\Library\libs

cmake -LAH -G"NMake Makefiles"                  ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"    ^
      -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"       ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
