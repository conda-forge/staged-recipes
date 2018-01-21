"%PYTHON%" setup.py install || exit 1
copy python\*.py "%RECIPE_DIR%"
