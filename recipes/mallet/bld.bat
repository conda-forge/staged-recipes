setlocal EnableDelayedExpansion

robocopy %SRC_DIR%\%PKG_NAME%-%PKG_VERSION% %PREFIX% /COPYALL /E

if not exist %PREFIX%\etc\conda\activate.d mkdir %PREFIX%\etc\conda\activate.d
copy %RECIPE_DIR%\activate.bat %PREFIX%\etc\conda\activate.d\%PKG_NAME%_activate.bat