copy "%RECIPE_DIR%\build.sh" .
set PREFIX=%PREFIX:\=/%
bash -lc "./build.sh" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
