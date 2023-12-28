@echo on

bash %RECIPE_DIR%/build_win.sh
IF %ERRORLEVEL% NEQ 0 exit 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
IF %ERRORLEVEL% NEQ 0 exit 1
