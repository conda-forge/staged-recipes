copy "%RECIPE_DIR%\pyproject.toml" "%SRC_DIR%\python\runfiles\"
cd "%SRC_DIR%\python\runfiles"

powershell -Command "(Get-Content pyproject.toml) -replace 'version = \"0.0.0\"', 'version = \"%PKG_VERSION%\"' | Set-Content pyproject.toml"

"%PYTHON%" -m pip install --no-deps --no-build-isolation . -vv
if errorlevel 1 exit 1
