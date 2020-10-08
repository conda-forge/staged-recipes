python build.py
if errorlevel 1 exit 1

:: copy nvvm and libdevice into the DLLs folder so numba can use them
mkdir "%PREFIX%\DLLs"
xcopy /s /y "%PREFIX%\Library\bin\nvvm*" "%PREFIX%\DLLs\"
if errorlevel 1 exit 1
xcopy /s /y "%PREFIX%\Library\bin\libdevice*" "%PREFIX%\DLLs\"
if errorlevel 1 exit 1
