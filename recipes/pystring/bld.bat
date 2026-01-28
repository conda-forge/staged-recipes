@echo on
SetLocal EnableDelayedExpansion

cmake -G "Ninja"                            ^
-DCMAKE_BUILD_TYPE=Release                  ^
-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%     ^
-DCMAKE_INSTALL_LIBDIR=lib                  ^
-DCMAKE_CXX_STANDARD=11                     ^
-DCMAKE_CXX_STANDARD_REQUIRED=ON            ^
-DCMAKE_POLICY_VERSION_MINIMUM=3.5          ^
..
if errorlevel 1 exit /b 1

cmake --build . -j%CPU_COUNT% --config Release --target install
if errorlevel 1 exit /b 1
