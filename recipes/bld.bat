copy "%RECIPE_DIR%\build.sh" .
set CHERE_INVOKING=1
bash -lc "./build.sh"
if errorlevel 1 exit 1
exit 0
