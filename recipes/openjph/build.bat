mkdir build
cd build

cmake -GNinja                                   ^
    %CMAKE_ARGS%                                ^
    -DOJPH_BUILD_EXECUTABLES=ON                 ^
    ..

if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
