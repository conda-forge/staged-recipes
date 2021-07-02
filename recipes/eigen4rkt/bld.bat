@REM Configure the build of eigen4rkt
cmake -S . -B build                           ^
    -DCMAKE_BUILD_TYPE=Release                ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%      ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%   ^
    -DEIGEN_BUILD_PKGCONFIG=ON

if errorlevel 1 exit 1

@REM Build and install eigen4rkt in %LIBRARY_PREFIX%
@REM Note: No need for --parallel below, since cmake takes care of the /MP flag for MSVC
cmake --build build --config Release --target install

if errorlevel 1 exit 1
