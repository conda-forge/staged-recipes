@echo on

mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

cmake ^
    -G "Ninja" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    %cd%\..\source
if errorlevel 1 exit 1

dir

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
