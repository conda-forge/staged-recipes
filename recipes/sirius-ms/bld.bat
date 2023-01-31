SET outdir=%PREFIX%/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

if not exist "%outdir%" mkdir "%outdir%"

xcopy /e /k /h /i /q "%cd%" "%outdir%"
if errorlevel 1 exit 1

ECHO "SHOW BUILD FILES 1"
dir "%outdir%"

ECHO "REMOVE BUNDLED RUNTIME"
rmdir /s /q "%outdir%\runtime"
if errorlevel 1 exit 1

ECHO "SHOW BUILD FILES 2"
dir "%outdir%"

ECHO "SHOW BIN DIR 1"
dir "%PREFIX%\bin"

ECHO "LINK EXE FILES TO BIN"
mklink "%outdir%\sirius.exe" "%PREFIX%\bin\sirius"
mklink "%outdir%\sirius-gui.exe" "%PREFIX%\bin\sirius-gui"

ECHO "SHOW BIN DIR 2"
dir "%PREFIX%\bin"