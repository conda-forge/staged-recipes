:: echo
echo off

:: build
mkdir build
cd build

:: PKG_CONFIG_PATH
set PKG_CONFIG_PATH=^
%BUILD_PREIX%\Library\lib\pkgconfig;^
%BUILD_PREIX%\Library\share\pkgconfig;
ehco PKG_CONFIG_PATH=%PKG_CONFIG_PATH%

:: cmake
cmake -S %SRC_DIR% -B . ^
   -G "NMake Makefiles" ^
   -D CMAKE_BUILD_TYPE=Release ^
   -D cmake_install_prefix="%PREFIX%\Library" ^
   -D cmake_search_prefix="%BUILD_PREFIX%\Library" ^
   -D extra_cxx_flags="" ^
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

echo 'bld.bat: OK'
