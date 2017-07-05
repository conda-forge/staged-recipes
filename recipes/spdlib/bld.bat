
cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D HDF5_INCLUDE_DIR=%LIBRARY_INC% ^
    -D HDF5_LIB_PATH=%LIBRARY_LIB% ^
    -D LIBLAS_INCLUDE_DIR=%LIBRARY_INC% ^
    -D LIBLAS_LIB_PATH=%LIBRARY_LIB% ^
    -D GSL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GSL_LIB_PATH=%LIBRARY_LIB% ^
    -D CGAL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D CGAL_LIB_PATH=%LIBRARY_LIB% ^
    -D BOOST_INCLUDE_DIR=%LIBRARY_INC% ^
    -D BOOST_LIB_PATH=%LIBRARY_LIB% ^
    -D GDAL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GDAL_LIB_PATH=%LIBRARY_LIB% ^
    -D XERCESC_INCLUDE_DIR=%LIBRARY_INC% ^
    -D XERCESC_LIB_PATH=%LIBRARY_LIB% ^
    -D GMP_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GMP_LIB_PATH=%LIBRARY_LIB% ^
    -D MPFR_INCLUDE_DIR=%LIBRARY_INC% ^
    -D MPFR_LIB_PATH=%LIBRARY_LIB% ^
    .

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: now Python bindings
cd python
cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%STDLIB_DIR% ^
    -D HDF5_INCLUDE_DIR=%LIBRARY_INC% ^
    -D HDF5_LIB_PATH=%LIBRARY_LIB% ^
    -D SPDLIB_IO_INCLUDE_DIR=%LIBRARY_INC% ^
    -D SPDLIB_IO_LIB_PATH=%LIBRARY_LIB% ^
    -D CMAKE_VERBOSE_MAKEFILE=ON ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    .
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: now the 'ng' python bindings
cd ..\ngpython
%PYTHON% setup.py build --gdalinclude=%LIBRARY_INC% \
    --boostinclude=%LIBRARY_INC% \
    --gslinclude=%LIBRARY_INC% \
    --cgalinclude=%LIBRARY_INC% \
    --lasinclude=%LIBRARY_INC% \
    --hdf5include=%LIBRARY_INC%
if errorlevel 1 exit 1

%PYTHON% setup.py install
if errorlevel 1 exit 1

cd ..
