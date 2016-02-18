set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%

set GEOS_LIBRARY_PATH=%LIBRARY_BIN%\geos_c.dll

%PYTHON% setup.py build_ext -I %LIBRARY_INC% -L %LIBRARY_LIB% -l geos_c
%PYTHON% setup.py install
if errorlevel 1 exit 1
