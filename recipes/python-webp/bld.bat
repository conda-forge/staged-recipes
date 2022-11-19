@echo on

del pyproject.toml
if errorlevel 1 exit 1

REM Copy over our simplified building recipe
copy %RECIPE_DIR%\builder.py webp_build\builder.py
if errorlevel 1 exit 1

REM Remove conan from setup_requires
python %RECIPE_DIR%\rewrite_config.py

python -m pip install . -vv --no-deps
if errorlevel 1 exit 1

