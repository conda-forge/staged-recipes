cd "%RECIPE_DIR%\.." || exit 1
"%PYTHON%" setup.py install || exit 1
copy python\*.py "%RECIPE_DIR%"
