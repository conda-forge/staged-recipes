@echo off

:: Setuptools SCM configuration
set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

:: Install the package using pip
%PYTHON% -m pip install --no-deps --no-build-isolation -vv .

:: Replace PKG_VERSION in activate.bat with the actual version
powershell -Command "(Get-Content %RECIPE_DIR%\scripts\activate.bat) -replace 'PKG_VERSION', '%PKG_VERSION%' | Set-Content %RECIPE_DIR%\scripts\activate.bat"

:: Install the conda activation and deactivation scripts
for %%F in (activate deactivate) do (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    copy %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)