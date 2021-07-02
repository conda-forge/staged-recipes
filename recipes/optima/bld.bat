@REM Configure the build of Optima
cmake -S . -B build                         ^
    -DCMAKE_BUILD_TYPE=Release              ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INCLUDE_PATH=%LIBRARY_INC%      ^
    -DCMAKE_VERBOSE_MAKEFILE=ON             ^
    -DOPTIMA_PYTHON_INSTALL_PREFIX=%PREFIX% ^
    -DPYTHON_EXECUTABLE=%PYTHON%

@REM Build and install Optima in %LIBRARY_PREFIX%
@REM Note: No need for --parallel below, since cmake takes care of the /MP flag for MSVC
cmake --build build --config Release --target install
