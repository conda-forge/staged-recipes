SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

xcopy /e /k /h /i /q %cd% %outdir%
if errorlevel 1 exit 1

powershell Compress-Archive -Path %outdir%\runtime -DestinationPath %outdir%\runtime.zip
if errorlevel 1 exit 1

rmdir %outdir%\runtime
if errorlevel 1 exit 1

powershell Compress-Archive -Path %outdir%\*.dll -DestinationPath %outdir%\dll.zip
if errorlevel 1 exit 1

del %outdir%\*.dll
if errorlevel 1 exit 1

mklink %PREFIX%\bin\sirius.exe %outdir%\sirius.exe
if errorlevel 1 exit 1

dir %outdir%
if errorlevel 1 exit 1
