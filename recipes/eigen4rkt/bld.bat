@REM Configure the build of eigen4rkt
cmake -S . -B build                           ^
    -DCMAKE_BUILD_TYPE=Release                ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%      ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%   ^
    -DEIGEN_BUILD_PKGCONFIG=ON

if errorlevel 1 exit 1

@REM Build and install eigen4rkt in %LIBRARY_PREFIX%
@REM Note: No need for --parallel below, since cmake takes care of the /MP flag for MSVC
@REM Install eigen via ExternalProject_Add (no need for --target install)
cmake --build build --config Release

if errorlevel 1 exit 1
