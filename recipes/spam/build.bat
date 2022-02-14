DIR
cd %RECIPE_DIR%
"%PYTHON%" ./spam/setup.py install

if errorlevel 1 exit 1
