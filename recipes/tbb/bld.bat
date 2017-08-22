
@rem See https://github.com/wjakob/tbb
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
cp "%RECIPE_DIR%\version_string.ver.in" build
if errorlevel 1 exit 1

mkdir buildw && cd buildw

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                             ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
  -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%"                      ^
  -DTBB_BUILD_TESTS=OFF                                    ^
  ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
