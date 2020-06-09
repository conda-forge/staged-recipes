
echo making_directory
mkdir %PREFIX%\bin
if errorlevel 1 exit 1

echo "current working"
echo %cd%
echo "contents of current working"
dir \b
echo "prefix directory"
echo %PREFIX%
echo "contents of prefix directory"
dir %PREFIX%
echo "source directory"
echo %SRC%
echo "contents of source directory"
dir %SRC%

echo moving_executable
move "%SRC%\msms.*.%PKG_VERSION%" "%PREFIX%\bin\msms"
if errorlevel 1 exit 1
