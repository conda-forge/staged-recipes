mkdir build
cd build

cmake .. -G "MinGW Makefiles" -D CMAKE_Fortran_FLAGS="-ffree-line-length-0"
make
