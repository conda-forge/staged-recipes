
REM echo making_directory
REM mkdir %PREFIX%\bin
REM if errorlevel 1 exit 1

dir %PREFIX%
dir %SRC%
dir "%SRC_DIR%"
dir "%RECIPE_DIR%"

echo moving_executable
move "msms.*.%PKG_VERSION%" "%PREFIX%\bin\msms"
if errorlevel 1 exit 1
dir "%PREFIX%\bin"
