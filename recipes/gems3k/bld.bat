mkdir build
cd build

@REM Configure the build of GEMS3K
cmake -GNinja ..                               ^
    -DCMAKE_BUILD_TYPE=Release                 ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
    -DCMAKE_INCLUDE_PATH=%LIBRARY_INC%

@REM Build and install GEMS3K in %LIBRARY_PREFIX%
ninja install
