
mkdir %PREFIX%\bin
if errorlevel 1 exit 1

move msms.*.%PKG_VERSION% %PREFIX%\bin\msms
if errorlevel 1 exit 1
