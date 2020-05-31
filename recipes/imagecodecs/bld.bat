REM Original setup.py file just isn't portable
copy %RECIPE_DIR%\setup.py %SRC_DIR%\setup.py

%PYTHON% -m pip install . -vv
