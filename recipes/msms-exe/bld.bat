

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

dir "%SRC_DIR%"

echo moving_executable
move "msms.exe" "%PREFIX%\bin\"
if errorlevel 1 exit 1
dir "%PREFIX%\bin"
