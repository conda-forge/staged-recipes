SET outdir=%PREFIX%\bin

powershell -Command "Expand-Archive -LiteralPath %outdir%\runtime.zip -DestinationPath %outdir%"
if errorlevel 1 exit 1

del %outdir%\runtime.zip
if errorlevel 1 exit 1

powershell -Command "Expand-Archive -LiteralPath %outdir%\dlls.zip -DestinationPath %outdir%"
if errorlevel 1 exit 1

del %outdir%\dlls.zip
if errorlevel 1 exit 1