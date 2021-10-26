SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

xcopy /e /k /h /i /q %cd% %outdir%
if errorlevel 1 exit 1

powershell -Command "Compress-Archive -Path %outdir%\runtime -DestinationPath %outdir%\runtime.zip"
if errorlevel 1 exit 1

rmdir /s /q %outdir%\runtime
if errorlevel 1 exit 1

powershell -Command "Get-ChildItem -Path %outdir%\*.dll | Compress-Archive -DestinationPath %outdir%\dlls.zip"
if errorlevel 1 exit 1

del %outdir%\*.dll
if errorlevel 1 exit 1

cd %PREFIX%
if errorlevel 1 exit 1

mklink bin\sirius.exe share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%\sirius.exe
if errorlevel 1 exit 1

dir %outdir%
if errorlevel 1 exit 1
