SET outdir=%PREFIX%/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

xcopy /e /k /h /i /q "%cd%" "%outdir%"
if errorlevel 1 exit 1

ECHO "SHOW INSTALLED FILES"
dir %outdir%

ECHO "REMOVE BUNDLED RUNTIME"
rmdir /s /q "%outdir%\runtime"
if errorlevel 1 exit 1

ECHO "LINK EXE FILES TO BIN"
mklink "%outdir%\sirius.exe" "%PREFIX%\bin\sirius"
mklink "%outdir%\sirius-gui.exe" "%PREFIX%\bin\sirius-gui"