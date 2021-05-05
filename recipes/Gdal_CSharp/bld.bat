call "%RECIPE_DIR%\set_bld_opts.bat"
if errorlevel 1 exit 1

cd swig\csharp
if errorlevel 1 exit 1

copy /B "%RECIPE_DIR%\gdal_test.cs" apps
if errorlevel 1 exit 1

nmake /f "%RECIPE_DIR%\makefile.vc" interface
if errorlevel 1 exit 1

nmake /f "%RECIPE_DIR%\makefile.vc" %BLD_OPTS%
if errorlevel 1 exit 1

nmake /f "%RECIPE_DIR%\makefile.vc" test
if errorlevel 1 exit 1

copy /B *.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B *.exe %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B *.json %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B *.pdb %LIBRARY_BIN%
if errorlevel 1 exit 1