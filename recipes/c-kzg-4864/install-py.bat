@echo off

for /f "delims=" %%i in ('python %RECIPE_DIR%\helpers\get_abi.py') do set TAG=%%i

%PYTHON% -m pip install %SRC_DIR%\wheels\%PKG_NAME%-%PKG_VERSION%-%TAG%.whl ^
--no-build-isolation ^
--no-deps ^
--only-binary :all: ^
--prefix "%PREFIX%"
if errorlevel 1 exit 1
