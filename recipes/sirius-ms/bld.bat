SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
if errorlevel 1 exit 1

xcopy /e /k /h /i /q %cd% %outdir%
if errorlevel 1 exit 1

REM powershell Compress-Archive -Path %outdir%\runtime -DestinationPath %outdir%\runtime.zip
REM if errorlevel 1 exit 1

REM rmdir /s /q %outdir%\runtime
REM if errorlevel 1 exit 1

powershell Compress-Archive -Path %outdir% -DestinationPath %outdir%.zip
if errorlevel 1 exit 1

rmdir /s /q %outdir%
if errorlevel 1 exit 1

REM powershell Compress-Archive -Path %outdir%\*.dll -DestinationPath %outdir%\dll.zip
REM if errorlevel 1 exit 1

REM del %outdir%\*.dll
REM if errorlevel 1 exit 1

REM mklink %PREFIX%\bin\sirius.exe %outdir%\sirius.exe
REM if errorlevel 1 exit 1

REM dir %outdir%
REM if errorlevel 1 exit 1
