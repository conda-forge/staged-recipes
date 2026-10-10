@echo off
set PYTHONIOENCODING=utf-8
"%PYTHON%" "%RECIPE_DIR%\build_recipe.py"
if errorlevel 1 exit 1
