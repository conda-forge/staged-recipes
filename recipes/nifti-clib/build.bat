@echo on

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DCMAKE_C_FLAGS="%CFLAGS% /DNIFTICDF_BUILD_SHARED" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DNIFTI_BUILD_APPLICATIONS=ON ^
    -DUSE_NIFTICDF_CODE=ON ^
    -DUSE_NIFTI2_CODE=ON ^
    -DUSE_CIFTI_CODE=ON ^
    -DUSE_FSL_CODE=OFF ^
    -DNIFTI_BUILD_TESTING=ON ^
    -DDOWNLOAD_TEST_DATA=ON
if %ERRORLEVEL% neq 0 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

ctest --test-dir build -V --output-on-failure --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

cmake --install build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1
