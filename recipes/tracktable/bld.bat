@REM Build conda package using pip wheel file
SET
cd %RECIPE_DIR%
dir
echo BUILD NUMBER %PKG_BUILDNUM%
if "%PKG_BUILDNUM%" == "0" (
    pip install ..\..\build\%PKG_NAME%-%PKG_VERSION%-cp%CONDA_PY%-none-win_amd64.whl --no-deps
    if errorlevel 1 exit 1
)
else (
    pip install ..\..\build\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%-cp%CONDA_PY%-none-win_amd64.whl --no-deps
    if errorlevel 1 exit 1
)
if errorlevel 1 exit 1