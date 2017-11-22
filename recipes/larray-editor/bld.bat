"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
:: Add more build steps here, if they are necessary.

:: https://github.com/ContinuumIO/menuinst/wiki/Menus-in-Conda-Recipes
if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
copy "%RECIPE_DIR%\larray-editor.json" "%PREFIX%\Menu"
copy "%SRC_DIR%\larray_editor\images\larray.ico" "%PREFIX%\Menu"
copy "%SRC_DIR%\larray_editor\images\larray-help.ico" "%PREFIX%\Menu"

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.
