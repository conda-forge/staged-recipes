mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

# enable_blaslib=OFF so OpenBLAS will be found instead of the built-in BLAS

cmake .. ^
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" ^
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" ^
    -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" ^
    -Denable_blaslib=OFF ^
    -Denable_single=ON ^
    -Denable_double=ON ^
    -Denable_complex16=ON ^
    -Denable_complex=ON ^
    -Denable_tests=ON ^
    -Denable_doc=OFF ^
    -Denable_matlab_mex=OFF
if errorlevel 1 exit 1
make
if errorlevel 1 exit 1
make test
if errorlevel 1 exit 1
make install
if errorlevel 1 exit 1
