xcopy /f /y pc\* .
if errorlevel 1 exit 1

%PYTHON% %RECIPE_DIR%\win_patch_makefile.py
if errorlevel 1 exit 1

mingw32-make mingw32 -j %NUM_CPUS%
if errorlevel 1 exit 1

mingw32-make install
if errorlevel 1 exit 1
