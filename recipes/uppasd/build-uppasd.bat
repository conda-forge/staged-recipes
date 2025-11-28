setlocal EnableDelayedExpansion

md build

cmake -S . -B build ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_Fortran_FLAGS="-I%PREFIX%\Library\include" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    %CMAKE_ARGS% ^
    -DUSE_MKL:BOOL=ON ^
    -DUSE_MKL_FFT:BOOL=ON ^
    -DUSE_OPENMP:BOOL=ON ^
    -DUSE_VSL:BOOL=ON
if %ERRORLEVEL% NEQ 0 exit 1

cmake --build build --parallel %CPU_COUNT%
if %ERRORLEVEL% NEQ 0 exit 1

cmake --install build --prefix %LIBRARY_PREFIX%
if %ERRORLEVEL% NEQ 0 exit 1
