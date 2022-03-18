:: Save source for C code and remove compiled libraries
ren "%SP_DIR%\goodvibes\share\symmetry.c" symmetry.c
rd /S /Q "%SP_DIR%\goodvibes\share\"

:: Install Python
"%PYTHON%" -m pip install . -vv

:: Compile C code and move to expected destination
"%CC%" -c symmetry.c
"%CC%" -shared -o "%SP_DIR%\goodvibes\share\symmetry_win.dll" symmetry.o 
