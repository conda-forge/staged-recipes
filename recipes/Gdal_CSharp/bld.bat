call "%RECIPE_DIR%\set_bld_opts.bat"

cd swig\csharp
if errorlevel 1 exit 1

copy /B "%LIBRARY_PREFIX%\lib\gdal_i.lib" ..\..
if errorlevel 1 exit 1
dir ..\..

nmake /f makefile.vc interface

nmake /f makefile.vc %BLD_OPTS%
if errorlevel 1 exit 1

call "%RECIPE_DIR%\move_output.bat"