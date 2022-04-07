@echo on

:: Save source for C code and remove compiled libraries
copy "%SRC_DIR%\goodvibes\share\symmetry.c" symmetry.c || goto :error
copy "%SRC_DIR%\goodvibes\share\LICENSE.txt" symmetry.LICENSE.txt || goto :error
rd /S /Q "%SRC_DIR%\goodvibes\share\" || goto :error

:: Install Python
"%PYTHON%" -m pip install . -vv || goto :error


:: Compile C code and move to expected destination
md %SP_DIR%\goodvibes\share\ || goto :error
"%CC%" /LD symmetry.c /LINK /OUT:"%SP_DIR%\goodvibes\share\symmetry_win.dll" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
