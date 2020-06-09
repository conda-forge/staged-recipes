
echo making_directory
mkdir %PREFIX%\bin
if errorlevel 1 exit 1

echo moving_executable
move msms.*.%PKG_VERSION% %PREFIX%\bin\msms
if errorlevel 1 exit 1
