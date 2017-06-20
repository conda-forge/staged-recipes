if "%ARCH%"=="64" (
    set WIN64="WIN64=YES"
) else (
    set WIN64=
)

:: Work out MSVC_VER - needed for build process.
:: Currently guess from Python version
if "%CONDA_PY%" == "27" (
    set MSVC_VER=1500
)
if "%CONDA_PY%" == "34" (
    set MSVC_VER=1600
)
if "%CONDA_PY%" == "35" (
    set MSVC_VER=1900
)
if "%CONDA_PY%" == "36" (
    set MSVC_VER=1900
)

if "%MSVC_VER%"=="" (
    echo "Python version not supported. Please update bld.bat"
    exit 1
)

:: Need consistent flags between build and install.
set BLD_OPTS=%WIN64% ^
    MSVC_VER=%MSVC_VER% ^
    GDAL_HOME=%LIBRARY_PREFIX% ^
    BINDIR=%LIBRARY_BIN% ^
    LIBDIR=%LIBRARY_LIB% ^
    INCDIR=%LIBRARY_INC% ^
    DATADIR=%LIBRARY_PREFIX%\share\gdal ^
    HTMLDIR=%LIBRARY_PREFIX%\share\doc\gdal ^
    CURL_INC="-I%LIBRARY_INC%" ^
    CURL_LIB="%LIBRARY_LIB%\libcurl.lib wsock32.lib wldap32.lib winmm.lib" ^
    EXPAT_DIR=%LIBRARY_PREFIX% ^
    EXPAT_INCLUDE="-I%LIBRARY_INC%" ^
    EXPAT_LIB=%LIBRARY_LIB%\expat.lib ^
    FREEXL_CFLAGS="-I%LIBRARY_INC%" ^
    FREEXL_LIBS=%LIBRARY_LIB%\freexl_i.lib ^
    GEOS_CFLAGS="-I%LIBRARY_INC% -DHAVE_GEOS" ^
    GEOS_DIR=%LIBRARY_PREFIX% ^
    GEOS_LIB=%LIBRARY_LIB%\geos_c.lib ^
    HDF4_DIR=%LIBRARY_PREFIX% ^
    HDF4_HAS_MAXOPENFILES=YES ^
    HDF4_LIB="%LIBRARY_LIB%\hdf.lib %LIBRARY_LIB%\mfhdf.lib %LIBRARY_LIB%\xdr.lib" ^
    HDF5_DIR=%LIBRARY_PREFIX% ^
    HDF5_LIB=%LIBRARY_LIB%\hdf5.lib ^
    JPEGDIR=%LIBRARY_INC% ^
    JPEG_EXTERNAL_LIB=1 ^
    JPEG_LIB=%LIBRARY_LIB%\libjpeg.lib ^
    KEA_CFLAGS="-I%LIBRARY_INC%" ^
    KEA_LIB=%LIBRARY_LIB%\libkea.lib ^
    NETCDF_INC_DIR=%LIBRARY_INC% ^
    NETCDF_LIB=%LIBRARY_LIB%\netcdf.lib ^
    NETCDF_SETTING=yes ^
    OPENJPEG_CFLAGS="-I%LIBRARY_INC%" ^
    OPENJPEG_ENABLED=YES ^
    OPENJPEG_LIB=%LIBRARY_LIB%\openjp2.lib ^
    OPENJPEG_VERSION=20100 ^
    PG_INC_DIR=%LIBRARY_INC% ^
    PG_LIB=%LIBRARY_LIB%\libpq.lib ^
    PNGDIR=%LIBRARY_INC% ^
    PNG_EXTERNAL_LIB=1 ^
    PNG_LIB=%LIBRARY_LIB%\libpng.lib ^
    PROJ_FLAGS=-DPROJ_STATIC ^
    PROJ_INCLUDE="-I%LIBRARY_INC%" ^
    PROJ_LIBRARY=%LIBRARY_LIB%\proj.lib ^
    SPATIALITE_412_OR_LATER=yes ^
    SQLITE_INC="-I%LIBRARY_INC% -DHAVE_SPATIALITE" ^
    SQLITE_LIB="%LIBRARY_LIB%\sqlite3.lib %LIBRARY_LIB%\spatialite_i.lib" ^
    TIFF_INC="-I%LIBRARY_INC%" ^
    TIFF_LIB=%LIBRARY_LIB%\libtiff_i.lib ^
    TIFF_OPTS=-DBIGTIFF_SUPPORT ^
    XERCES_DIR=%LIBRARY_PREFIX% ^
    XERCES_INCLUDE="-I%LIBRARY_INC% -I%LIBRARY_INC%\xercesc" ^
    XERCES_LIB=%LIBRARY_LIB%\xerces-c_3.lib

nmake /f makefile.vc %BLD_OPTS%
if errorlevel 1 exit 1

mkdir -p %LIBRARY_PREFIX%\share\doc\gdal

nmake /f makefile.vc devinstall %BLD_OPTS%
if errorlevel 1 exit 1

copy *.lib %LIBRARY_LIB%\ || exit 1
if errorlevel 1 exit 1

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\gdal-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\gdal-deactivate.bat
if errorlevel 1 exit 1

:: Copy unix shell activation scripts, needed by Windows Bash users
copy %RECIPE_DIR%\scripts\activate.sh %ACTIVATE_DIR%\gdal-activate.sh
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.sh %DEACTIVATE_DIR%\gdal-deactivate.sh
if errorlevel 1 exit 1
