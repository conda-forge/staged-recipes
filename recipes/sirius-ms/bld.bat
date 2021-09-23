SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

xcopy /e /k /h /i /q %cd% %outdir%
if errorlevel 1 exit 1

mklink %PREFIX%\bin\sirius.exe %outdir%\sirius.exe
if errorlevel 1 exit 1