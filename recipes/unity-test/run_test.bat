mkdir build
pushd build

cmake ../ -G "Ninja"
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake_build_test.exe
if errorlevel 1 exit 1

popd