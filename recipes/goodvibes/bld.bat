"%PYTHON%" -m pip install . -vv

"%CC%" -c symmetry.c
"%CC%" -shared -o %SP_DIR%\goodvibes\share\symmetry_win.dll symmetry.o 