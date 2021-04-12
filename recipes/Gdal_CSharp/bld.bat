call "%RECIPE_DIR%\set_bld_opts.bat"
if errorlevel 1 exit 1

cd swig\csharp
if errorlevel 1 exit 1

copy /B "%LIBRARY_PREFIX%\lib\gdal_i.lib" ..\..
if errorlevel 1 exit 1

nmake /f makefile.vc interface
if errorlevel 1 exit 1

nmake /f makefile.vc %BLD_OPTS%
if errorlevel 1 exit 1

nmake /f makefile.vc test
if errorlevel 1 exit 1

call "%RECIPE_DIR%\move_output.bat"
if errorlevel 1 exit 1