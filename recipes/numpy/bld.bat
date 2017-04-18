(
echo [DEFAULT]
echo library_dirs = %LIBRARY_LIB%
echo include_dirs = %LIBRARY_INC%
echo.
echo [atlas]
echo atlas_libs = openblas
echo libraries = openblas
echo.
echo [openblas]
echo libraries = openblas
echo library_dirs = %LIBRARY_LIB%
echo include_dirs = %LIBRARY_INC%
) > site.cfg

python setup.py build -j %CPU_COUNT% install --old-and-unmanageable
if errorlevel 1 exit 1
