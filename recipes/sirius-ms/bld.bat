SET outdir=%PREFIX%\bin

xcopy /e /k /h /i /q "%cd%" "%outdir%"
if errorlevel 1 exit 1

rmdir /s /q "%outdir%\runtime"
if errorlevel 1 exit 1