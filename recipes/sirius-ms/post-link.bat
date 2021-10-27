SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
if errorlevel 1 exit 1

mklink "%PREFIX%\Scripts\sirius.exe" "%outdir%\sirius.exe"
if errorlevel 1 exit 1

mklink "%PREFIX%\Scripts\sirius-gui.exe" "%outdir%\sirius-gui.exe"
if errorlevel 1 exit 1

powershell -Command "Expand-Archive -LiteralPath %outdir%\runtime.zip -DestinationPath %outdir%"
if errorlevel 1 exit 1

del %outdir%\runtime.zip
if errorlevel 1 exit 1

powershell -Command "Expand-Archive -LiteralPath %outdir%\dlls.zip -DestinationPath %outdir%"
if errorlevel 1 exit 1

del %outdir%\dlls.zip
if errorlevel 1 exit 1

dir %outdir%
if errorlevel 1 exit 1
