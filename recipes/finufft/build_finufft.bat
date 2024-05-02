@echo ON

if /I "%PKG_NAME%" == "libfinufft" (

    cmake ^
        -B build-lib/ ^
        -G Ninja ^
        %CMAKE_ARGS% ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DFINUFFT_USE_OPENMP=OFF ^
        -DFINUFFT_FFTW_SUFFIX=
    if errorlevel 1 exit 1
    cmake --build build-lib/ --parallel %CPU_COUNT%
    if errorlevel 1 exit 1
    cmake --install build-lib/

)
if /I "%PKG_NAME%" == "finufft" (

    %PYTHON% -m pip install --no-deps --no-build-isolation -vv ./python/finufft

)