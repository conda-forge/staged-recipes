"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1

for %%d in (activate deactivate) do (
    if not exist "%PREFIX%\etc\conda\%%d.d" mkdir "%PREFIX%\etc\conda\%%d.d"
    copy /Y "%RECIPE_DIR%\%%d.sh"  "%PREFIX%\etc\conda\%%d.d\r-rapp.sh"  || exit /B 1
    copy /Y "%RECIPE_DIR%\%%d.bat" "%PREFIX%\etc\conda\%%d.d\r-rapp.bat" || exit /B 1
    copy /Y "%RECIPE_DIR%\%%d.ps1" "%PREFIX%\etc\conda\%%d.d\r-rapp.ps1" || exit /B 1
)
