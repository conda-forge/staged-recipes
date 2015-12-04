set SITECFG=%SRC_DIR%/setup.cfg

echo [options] > %SITECFG%
echo use_cython=True >> %SITECFG%
echo [directories] >> %SITECFG%
echo HDF5_libdir = %LIBRARY_LIB% >> %SITECFG%
echo HDF5_incdir = %LIBRARY_INC% >> %SITECFG%
echo netCDF4_libdir = %LIBRARY_LIB% >> %SITECFG%
echo netCDF4_incdir = %LIBRARY_INC% >> %SITECFG%

"%PYTHON%" setup.py install --single-version-externally-managed  --record record.txt
if errorlevel 1 exit 1
