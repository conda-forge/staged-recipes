copy "%RECIPE_DIR%\build.sh" .
set PREFIX=%PREFIX:\=/%
bash -lc "./build.sh"
IF %ERRORLEVEL% NEQ 0 exit 1
