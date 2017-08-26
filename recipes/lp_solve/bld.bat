@rem See https://github.com/PADrend/ThirdParty 
copy "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1

mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_BUILD_TYPE=%CMAKE_CONFIG%                        ^
    -DBUILD_SHARED_LIBS=ON                                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

