setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %LIBRARY_PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST %LIBRARY_PREFIX%\etc\conda\%%F.d MKDIR %LIBRARY_PREFIX%\etc\conda\%%F.d
    COPY %RECIPE_DIR%/%%F.bat %LIBRARY_PREFIX%\etc\conda\%%F.d\toolchain_%%F.bat
)
