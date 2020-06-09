
REM echo making_directory
REM mkdir %PREFIX%\bin
REM if errorlevel 1 exit 1

dir %PREFIX%
dir %SRC%
dir "%RECIPE_DIR%"
cd\
dir msms_win32_* /s

echo moving_executable
move "%RECIPE_DIR%\msms.*.%PKG_VERSION%" "%PREFIX%\bin\msms"
if errorlevel 1 exit 1
dir "%PREFIX%\bin"
