setlocal EnableDelayedExpansion
SET packageName=%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%
SET outdir=%PREFIX%/share/%packageName%
SET siriusDistName=sirius

ECHO "### ENV INFO"
ECHO "PREFIX=%PREFIX%"
ECHO "CONDA_PREFIX=%CONDA_PREFIX%"
ECHO "LD_RUN_PATH=%LD_RUN_PATH%"
ECHO "packageName=%packageName%"
ECHO "outdir=%outdir%"
ECHO "siriusDistName=%siriusDistName%"
ECHO "### ENV INFO END"

ECHO "### Show Build dir"
dir "%cd%"

ECHO "### Run gradle build"
call .\gradlew.bat :sirius_dist:sirius_gui_multi_os:installDist -P "build.sirius.location.lib=%%CONDA_PREFIX%%\share\%packageName%\lib" -P "build.sirius.native.remove.linux=true" -P "build.sirius.native.remove.mac=true" -P "build.sirius.starter.remove.ix=true"
if errorlevel 1 exit 1

ECHO "### Create package dirs"
if not exist "%outdir%" mkdir "%outdir%"
if errorlevel 1 exit 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if errorlevel 1 exit 1

ECHO "### Copy jars"
xcopy /e /s /t /k /h /i /q /y "%cd%\sirius_dist\sirius_gui_multi_os\build\install\%siriusDistName%\*" "%outdir%\"
if errorlevel 1 exit 1

ECHO "### Remove bin"
rmdir /s /q "%outdir%\bin"
if errorlevel 1 exit 1

ECHO "### Show jar dir"
dir "%outdir%\lib"
if errorlevel 1 exit 1

ECHO "### Show bin dir source"
dir "%cd%\sirius_dist\sirius_gui_multi_os\build\install\%siriusDistName%\bin\"
if errorlevel 1 exit 1

ECHO "### Copy starters"
xcopy /e /s /t /k /h /i /q /y "%cd%\sirius_dist\sirius_gui_multi_os\build\install\%siriusDistName%\bin\*" "%PREFIX%\bin\"
if errorlevel 1 exit 1

ECHO "### Show bin dir target"
dir "%PREFIX%\bin"
if errorlevel 1 exit 1

ECHO "### Show start script"
dir "%PREFIX%\bin\sirius.bat"
type "%PREFIX%\bin\sirius.bat"
