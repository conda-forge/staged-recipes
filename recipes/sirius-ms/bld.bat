SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

xcopy /e /k /h /i /q %cd% %outdir%
if errorlevel 1 exit 1

tar -c -z -f %outdir%/runtime.tgz -C %outdir%/runtime .
if errorlevel 1 exit 1

rmdir %outdir%/runtime
if errorlevel 1 exit 1

cd %outdir%
if errorlevel 1 exit 1

tar -c -z -f dlls.tgz *.dll
if errorlevel 1 exit 1

del *.dll
if errorlevel 1 exit 1

mklink %PREFIX%\bin\sirius.exe %outdir%\sirius.exe
if errorlevel 1 exit 1