@echo on

sed -i "s|^char const \* const inam\[\]=|__declspec(dllexport) char const * const inam[]=|" nifticdf/nifticdf.c
if %ERRORLEVEL% neq 0 exit /b 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DNIFTI_BUILD_APPLICATIONS=ON ^
    -DUSE_NIFTICDF_CODE=ON ^
    -DUSE_NIFTI2_CODE=ON ^
    -DUSE_CIFTI_CODE=ON ^
    -DUSE_FSL_CODE=OFF ^
    -DNIFTI_BUILD_TESTING=ON ^
    -DDOWNLOAD_TEST_DATA=ON
if %ERRORLEVEL% neq 0 exit /b 1

cmake --build build --parallel 1 --verbose
if %ERRORLEVEL% neq 0 exit /b 1

ctest --test-dir build -V --output-on-failure --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

cmake --install build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1
