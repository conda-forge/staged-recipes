@echo on

set CXXFLAGS=%CXXFLAGS% /bigobj

cmake %CMAKE_ARGS% -S %SRC_DIR% -B build ^
-G Ninja  ^
-DCMAKE_BUILD_TYPE=Release  ^
-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
-DPACMAN_PYTHON_DIR=%SP_DIR%  ^
-DBUILD_TESTS=OFF  ^
-DBUILD_FORTRAN_INTERFACE=OFF  ^
if errorlevel 1 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build
if errorlevel 1 exit /b 1