mkdir build
pushd build

cmake -S ..                                ^
    -GNinja                                ^
    -DCMAKE_BUILD_TYPE=Release             ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%   ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% 

if errorlevel 1 exit 1

cmake --build . --target install --parallel %CPU_COUNT%
if errorlevel 1 exit 1

popd
