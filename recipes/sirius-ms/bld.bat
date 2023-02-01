SET packageName=%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%
SET outdir=%PREFIX%/share/$packageName
SET siriusDistName="sirius"

ECHO "### ENV INFO"
ECHO "PREFIX=%PREFIX%"
ECHO "CONDA_PREFIX=%CONDA_PREFIX%"
ECHO "LD_RUN_PATH=%LD_RUN_PATH%"
ECHO "packageName=%packageName%"
ECHO "outdir=%outdir%"
ECHO "siriusDistName=%siriusDistName%"
ECHO "### ENV INFO END"

ECHO "### Show Build dir"
dir .\

ECHO "### Run gradle build"
.\gradlew :sirius_dist:sirius_gui_multi_os:installDist^
    -P "build.sirius.location.lib"=%%CONDA_PREFIX%%\share\%packageName%\lib"^
    -P "build.sirius.native.remove.win=true"^
    -P "build.sirius.native.remove.linux=true"^
    -P "build.sirius.native.remove.mac=true"^
    -P "build.sirius.starter.remove.win=true"^

ECHO "### Create package dirs"
if not exist "%outdir%" mkdir "%outdir%"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

ECHO "### Copy jars"
xcopy /e /k /h /i /q .\sirius_dist\sirius_gui_multi_os\build\install\%siriusDistName%\* "%outdir%\"
if errorlevel 1 exit 1
rmdir /s /q "%outdir%\bin"
if errorlevel 1 exit 1

ECHO "### Show jar dir"
dir "%outdir%/lib"

ECHO "### Copy jars"
xcopy /e /k /h /i /q ./sirius_dist/sirius_gui_multi_os/build/install/%siriusDistName%/bin/* "%PREFIX%\bin\"

ECHO "### Show bin dir"
dir "%PREFIX%\bin"

echo "### Show start script"
dir "$PREFIX/bin/sirius.sh"
type "$PREFIX/bin/sirius.sh"
