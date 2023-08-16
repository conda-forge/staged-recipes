mkdir %PREFIX%\bin
if errorlevel 1 exit 1

move src\* %PREFIX%\bin
if errorlevel 1 exit 1

move src\include %PREFIX%\bin
if errorlevel 1 exit 1
