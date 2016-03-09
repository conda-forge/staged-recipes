
REM echo %PREFIX%
REM echo %LIBRARY_INC%
REM echo %LIBRARY_LIB%
REM exit 1

if %ARCH% == 64 (
    set WIN64FLAG=WIN64=YES
) else (
    set WIN64FLAG=
)

REM need consistent flags between build and install
set BLD_OPTS=MSVC_VER=1600 GDAL_HOME=%PREFIX% %WIN64FLAG% ^
PYDIR=%PREFIX% ^
HDF5_PLUGIN=NO ^
HDF5_DIR=%PREFIX% ^
HDF5_LIB=%PREFIX%\lib\hdf5.lib ^
GEOS_DIR=%PREFIX% ^
GEOS_CFLAGS="-I%PREFIX%\include -DHAVE_GEOS" ^
GEOS_LIB=%PREFIX%\lib\geos_c.lib ^
XERCES_DIR=%PREFIX% ^
XERCES_INCLUDE="-I%PREFIX%\include -I%PREFIX%\include\xercesc" ^
XERCES_LIB=%PREFIX%\lib\xerces-c_3.lib

nmake -f makefile.vc %BLD_OPTS%
if errorlevel 1 exit 1

nmake -f makefile.vc %BLD_OPTS% devinstall
if errorlevel 1 exit 1

cd swig\python
%PYTHON% setup.py build
if errorlevel 1 exit 1
%PYTHON% setup.py install
if errorlevel 1 exit 1
cd ..\..

REM Copy data files 
mkdir %PREFIX%\share\gdal\
copy data\*csv %PREFIX%\share\gdal\
copy data\*wkt %PREFIX%\share\gdal\

move %PREFIX%\bin\*.* %PREFIX%
if errorlevel 1 exit 1

REM PG_INC_DIR=%PREFIX% ^
REM PG_LIB=%PREFIX%\libpq.lib ^
rem NETCDF_PLUGIN=NO ^
rem NETCDF_SETTING=yes ^
rem NETCDF_LIB=%PREFIX%\netcdf.lib ^
rem NETCDF_INC_DIR=%PREFIX% ^
rem CURL_DIR=%PREFIX% ^
rem CURL_INC=-I%PREFIX% ^
rem CURL_LIB="%PREFIX%\libcurl.lib %PREFIX%\libeay32.lib %PREFIX%\ssleay32.lib" ^
rem CURL_CFLAGS=-DCURL_STATICLIB


