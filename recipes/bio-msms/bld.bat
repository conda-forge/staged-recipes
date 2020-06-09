mkdir %PREFIX%\bin
if errorlevel 1 exit 1

move "msms.exe" "%PREFIX%\bin\"
if errorlevel 1 exit 1
