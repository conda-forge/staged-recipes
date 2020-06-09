
echo making_directory
mkdir %PREFIX%\bin
if errorlevel 1 exit 1

echo %cd%
dir \b
dir %PREFIX%
if exist "msms.*.%PKG_VERSION%" ( echo "msms.*.%PKG_VERSION% exists" )
echo moving_executable
move "msms.*.%PKG_VERSION%" "%PREFIX%\bin\msms"
if errorlevel 1 exit 1
