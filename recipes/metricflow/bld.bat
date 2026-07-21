python "%RECIPE_DIR%\fix_symlinks.py"
if errorlevel 1 exit 1
python -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
