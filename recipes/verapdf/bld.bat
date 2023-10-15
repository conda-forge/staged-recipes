@echo on
set MAVEN_OPTS="-Xmx1G"

cd %SRC_DIR%

cmd.exe /c mvn --batch-mode versions:set -DnewVersion=%PKG_VERSION% || echo ""
cmd.exe /c mvn --batch-mode clean || echo ""
cmd.exe /c mvn --batch-mode -DskipTests clean install || echo ""

md tmp

cd tmp

unzip "..\installer\target/verapdf-greenfield-%PKG_VERSION%-installer.zip"
cd ".\verapdf-greenfield-%PKG_VERSION%"

copy "%SRC_DIR%\auto-install-tmp.xml" auto-install.xml
sed -iE "s;/tmp/verapdf;%LIBRARY_LIB%\\verapdf;" auto-install.xml
cmd.exe /c verapdf-install.bat auto-install.xml

echo cmd.exe /c %LIBRARY_LIB%\\verapdf\\verapdf.bat %%* > %LIBRARY_BIN%\verapdf.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\verapdf.cmd

echo cmd.exe /c %LIBRARY_LIB%\\verapdf\\verapdf-gui.bat %%* > %LIBRARY_BIN%\verapdf-gui.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\verapdf-gui.cmd
