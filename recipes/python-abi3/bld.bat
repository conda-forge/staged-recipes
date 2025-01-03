:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    sed "s/@PY_LIMITED_API/%PY_LIMITED_API%/g" %RECIPE_DIR%\scripts\%%F.bat >> %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: We also copy .sh scripts to be able to use them
    :: with POSIX CLI on Windows.
    sed "s/@PY_LIMITED_API/%PY_LIMITED_API%/g" %RECIPE_DIR%\scripts\%%F.sh >> %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
    if errorlevel 1 exit 1
)
