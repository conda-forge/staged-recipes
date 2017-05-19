if "%ARCH%"=="64" (
    set WIN64="WIN64=YES"
) else (
    set WIN64=
)

:: Need consistent flags between build and install.
set BLD_OPTS=%WIN64% ^
    GDAL_HOME=%LIBRARY_PREFIX% ^
    BINDIR=%LIBRARY_BIN% ^
    LIBDIR=%LIBRARY_LIB% ^
    INCDIR=%LIBRARY_INC% ^
    DATADIR=%LIBRARY_PREFIX%\share\gdal ^
    HTMLDIR=%LIBRARY_PREFIX%\share\doc\gdal ^
    HDF5_LIB=%LIBRARY_LIB%\hdf5.lib ^
    HDF5_DIR=%LIBRARY_PREFIX% ^
    GEOS_DIR=%LIBRARY_PREFIX% ^
    GEOS_CFLAGS="-I%LIBRARY_INC% -DHAVE_GEOS" ^
    GEOS_LIB=%LIBRARY_LIB%\geos_c.lib ^
    XERCES_DIR=%LIBRARY_PREFIX% ^
    XERCES_INCLUDE="-I%LIBRARY_INC% -I%LIBRARY_INC%\xercesc" ^
    XERCES_LIB=%LIBRARY_LIB%\xerces-c_3.lib ^
    HDF4_DIR=%LIBRARY_PREFIX% ^
    HDF4_LIB="%LIBRARY_LIB%\hdf.lib %LIBRARY_LIB%\mfhdf.lib %LIBRARY_LIB%\xdr.lib" ^
    NETCDF_LIB=%LIBRARY_LIB%\netcdf.lib ^
    NETCDF_INC_DIR=%LIBRARY_INC% ^
    NETCDF_SETTING=yes ^
    KEA_CFLAGS="-I%LIBRARY_INC%" ^
    KEA_LIB=%LIBRARY_LIB%\libkea.lib

nmake /f makefile.vc %BLD_OPTS%
if errorlevel 1 exit 1

mkdir -p %LIBRARY_PREFIX%\share\doc\gdal

nmake /f makefile.vc devinstall %BLD_OPTS%
if errorlevel 1 exit 1

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
mkdir %ACTIVATE_DIR%
copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\gdal-activate.bat
if errorlevel 1 exit 1

set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %DEACTIVATE_DIR%
copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\gdal-deactivate.bat
if errorlevel 1 exit 1
