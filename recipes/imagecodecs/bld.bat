REM Original setup.py file just isn't portable
cp %RECIPE_DIR%\setup_win.py %SRC_DIR%\setup.py
%PYTHON% -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
