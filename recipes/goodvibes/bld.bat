:: Save source for C code and remove compiled libraries
ren "%SRC_DIR%\goodvibes\share\symmetry.c" symmetry.c
rd /S /Q "%SRC_DIR%\goodvibes\share\"

:: Install Python
"%PYTHON%" -m pip install . -vv


:: Compile C code and move to expected destination
md %SP_DIR%\goodvibes\share\
"%CC%" /LD symmetry.c /F "%SP_DIR%\goodvibes\share\symmetry_win.dll"
