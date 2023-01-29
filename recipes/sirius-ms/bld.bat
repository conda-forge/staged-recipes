SET outdir=%PREFIX%\bin

xcopy /e /k /h /i /q "%cd%" "%outdir%"
if errorlevel 1 exit 1


::powershell -Command "Compress-Archive -Path %outdir%\runtime -DestinationPath %outdir%\runtime.zip"
::if errorlevel 1 exit 1

rmdir /s /q "%outdir%\runtime"
if errorlevel 1 exit 1

::powershell -Command "Get-ChildItem -Path %outdir%\*.dll | Compress-Archive -DestinationPath %outdir%\dlls.zip"
::if errorlevel 1 exit 1

::del "%outdir%\*.dll"
::if errorlevel 1 exit 1