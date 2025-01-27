mkdir build
cd build

:: cmake
cmake -S %SRCDIR%  -B . ^
   -G "NMake Makefiles" ^
   -D CMAKE_BUILD_TYPE=Release ^
   -D cmake_install_prefix=%LIBRARY_PREFIX% ^
   -D cmake_libdir=lib ^
   -D ldlt_cholmod=yes ^
   -D optimize_cppad_function=yes ^
   -D for_hes_sparsity=yes 
if errorlevel 1 exit 1

:: build
cmake --build . --config Release
if errorlevel 1 exit 1

:: check
cmake --build . --config Release --target check
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

