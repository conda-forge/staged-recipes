
mkdir build
cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                               ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"                        ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                     ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                  ^
  -DBUILD_SWIG_JAVA=OFF                                      ^
  -DBUILD_TESTS=OFF                                          ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target ALL
if errorlevel 1 exit 1

:: no install rule
copy fmippex.dll %LIBRARY_BIN% || exit 1
copy fmippim.dll %LIBRARY_BIN% || exit 1
copy import\swig\fmippim.py %SP_DIR% || exit 1
copy import\swig\_fmippim.pyd %SP_DIR% || exit 1

