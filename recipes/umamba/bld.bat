
cmake -S mamba ^
    -B build ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%PREFIX% ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D BUILD_LIBMAMBA=ON ^
    -D BUILD_SHARED=ON ^
    -D BUILD_MICROMAMBA=ON ^
    -G "Ninja"
if %errorlevel% NEQ 0 exit /b %errorlevel%

cmake --build build --parallel %CPU_COUNT%
if %errorlevel% NEQ 0 exit /b %errorlevel%

cmake --install build
if %errorlevel% NEQ 0 exit /b %errorlevel%
