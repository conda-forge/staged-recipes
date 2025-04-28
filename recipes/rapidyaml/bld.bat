@REM Git clone submodules
git submodule update --init --recursive

@REM Configure the build of the library
mkdir build
cd build
cmake -GNinja .. %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release

@REM Build and install the library in $PREFIX
ninja install
