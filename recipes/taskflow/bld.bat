cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% ^
                           -DTF_BUILD_EXAMPLES=OFF ^
                           -DTF_BUILD_TESTS=OFF ^
                           -DTF_BUILD_BENCHMARKS=OFF ^
                           -DTF_BUILD_CUDA=OFF ^
                           -DTF_BUILD_SYCL=OFF
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
