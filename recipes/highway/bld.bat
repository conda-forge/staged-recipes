mkdir c_build
cd c_build

cmake                                           ^
    -LAH -G "Ninja"                             ^
    %CMAKE_ARGS%                                ^
    -DCMAKE_BUILD_TYPE=Release                  ^
    -DBUILD_TESTING=OFF                         ^
    -DBUILD_SHARED_LIBS=ON                      ^
    -DHWY_ENABLE_INSTALL=ON                     ^
    -DHWY_ENABLE_EXAMPLES=OFF                   ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
    ..
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
