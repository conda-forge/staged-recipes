setlocal EnableDelayedExpansion

:: Copy the activate scripts to %PREFIX%\etc\conda\activate.d.
:: This will allow them to be run on environment activation.
if not exist %PREFIX%\etc\conda\activate.d mkdir %PREFIX%\etc\conda\activate.d
copy %RECIPE_DIR%\activate.bat %PREFIX%\etc\conda\activate.d\%PKG_NAME%-activate.bat
:: Copy unix shell activation scripts, needed by Windows Bash users
copy %RECIPE_DIR%\activate.sh %PREFIX%\etc\conda\activate.d\%PKG_NAME%-activate.sh
