@echo on

@REM CTest runs build-tree executables directly on Windows.
@REM Since the generated DLLs are placed in per-target build directories,
@REM add those directories to PATH to avoid 0xc0000135 DLL loader failures.
set "PATH=%SRC_DIR%\build\znzlib;%SRC_DIR%\build\niftilib;%SRC_DIR%\build\nifti2;%SRC_DIR%\build\cifti;%PATH%"

@REM Temporarily disable nifticdf on Windows.
@REM The current release lacks the DLL import/export fix for the nifticdf data symbol `inam`.
@REM Upstream master already contains the fix, so this should be re-enabled in the next release.
cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DNIFTI_BUILD_APPLICATIONS=ON ^
    -DUSE_NIFTICDF_CODE=OFF ^
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
