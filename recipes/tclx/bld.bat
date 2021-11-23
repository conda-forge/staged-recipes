copy %RECIPE_DIR%\build.sh build.sh
where tclsh
bash build.sh
if errorlevel 1 exit 1
exit 0
