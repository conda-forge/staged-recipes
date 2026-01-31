@echo on
SetLocal EnableDelayedExpansion

if not exist build mkdir build
cd build

cmake -G "Ninja" ^
%CMAKE_ARGS% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
-DCMAKE_INSTALL_LIBDIR=lib ^
-DCMAKE_CXX_STANDARD=11 ^
-DCMAKE_CXX_STANDARD_REQUIRED=ON ^
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
..

if errorlevel 1 exit /b 1

cmake --build . -j %CPU_COUNT% --verbose --config Release
if errorlevel 1 exit /b 1

cmake --build . --config Release --target install
if errorlevel 1 exit /b 1
