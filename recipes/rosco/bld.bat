mkdir build
cd build
if errorlevel 1 exit 1

cmake .. -G "MinGW Makefiles" -D CMAKE_Fortran_FLAGS="-ffree-line-length-0"
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1
