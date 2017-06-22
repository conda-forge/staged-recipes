
# attempt to debug cmake problem
echo %PATH%
where cmake

cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D INSTALL_PYTHON_USING_PREFIX=OFF ^
    -D PYTHON_EXE=%PYTHON% ^
    -D BOOST_INCLUDE_DIR=%LIBRARY_INC% ^
    -D BOOST_LIB_PATH=%LIBRARY_LIB% ^
    -D GDAL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GDAL_LIB_PATH=%LIBRARY_LIB% ^
    -D HDF5_INCLUDE_DIR=%LIBRARY_INC% ^
    -D HDF5_LIB_PATH=%LIBRARY_LIB% ^
    -D XERCESC_INCLUDE_DIR=%LIBRARY_INC% ^
    -D XERCESC_LIB_PATH=%LIBRARY_LIB% ^
    -D GSL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GSL_LIB_PATH=%LIBRARY_LIB% ^
    -D GEOS_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GEOS_LIB_PATH=%LIBRARY_LIB% ^
    -D MUPARSER_INCLUDE_DIR=%LIBRARY_INC% ^
    -D MUPARSER_LIB_PATH=%LIBRARY_LIB% ^
    -D CGAL_INCLUDE_DIR=%LIBRARY_LIB% ^
    -D CGAL_LIB_PATH=%LIBRARY_LIB% ^
    -D GMP_INCLUDE_DIR=%LIBRARY_INC% ^
    -D GMP_LIB_PATH=%LIBRARY_LIB% ^
    -D MPFR_INCLUDE_DIR=%LIBRARY_INC% ^
    -D MPFR_LIB_PATH=%LIBRARY_LIB% ^
    -D KEA_INCLUDE_DIR=%LIBRARY_INC% ^
    -D KEA_LIB_PATH=%LIBRARY_LIB% ^
    .
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

REM Must run tests now since they require the source tree
cd python_tests\RSGISLibTests
%PYTHON% RSGIStests.py --all
if errorlevel 1 exit 1

