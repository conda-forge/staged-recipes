setlocal EnableDelayedExpansion

md build
if errorlevel 1 exit 1

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_LIBDIR=lib ${CMAKE_ARGS} -DUSE_OPENMP:BOOL=ON -DUSE_FFTW:BOOL=OFF -DUSE_MKL:BOOL=OFF -DUSE_MKL_FFT:BOOL=OFF -DUSE_VSL:BOOL=OFF -DCMAKE_Fortran_FLAGS="-I%PREFIX%\Library\include"
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build --prefix %LIBRARY_PREFIX%
if errorlevel 1 exit 1

