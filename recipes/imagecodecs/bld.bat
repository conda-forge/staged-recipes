REM Original setup.py file just isn't portable
REM cp %RECIPE_DIR%\setup_win.py %SRC_DIR%\setup.py

set CFLAGS="%CFLAGS% /I%LIBRARY_INC%\openjpeg-%openjpeg%"
%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
