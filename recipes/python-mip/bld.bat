@echo on

:: take care of activation scripts;
:: from https://conda-forge.org/docs/maintainer/adding_pkgs.html#activate-scripts
setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    REM Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)

:: nuke vendored libraries
rmdir /q /s mip/libraries/

set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%
set PMIP_CBC_LIBRARY=%PREFIX%\\TODO.dll
python -m pip install . -vv --prefix=%PREFIX%
if %ERRORLEVEL% NEQ 0 exit 1
