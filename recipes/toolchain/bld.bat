setlocal EnableDelayedExpansion

FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST %LIBRARY_PREFIX%\etc\conda\%%F.d MKDIR %LIBRARY_PREFIX%\etc\conda\%%F.d
    COPY %RECIPE_DIR%/%%F.bat %LIBRARY_PREFIX%\etc\conda\%%F.d\toolchain_%%F.bat
)
