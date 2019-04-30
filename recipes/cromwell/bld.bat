REM batch script written as a by hand conversion of build.sh.

set outdir=%PREFIX%/share/%PKG_NAME%
MKDIR %outdir%
if errorlevel 1 exit 1
MKDIR %PREFIX%/bin
if errorlevel 1 exit 1

CD %SRC_DIR%
if errorlevel 1 exit 1

REM cromwell
COPY cromwell/cromwell-*.jar %outdir%/cromwell.jar
if errorlevel 1 exit 1
COPY %RECIPE_DIR%/cromwell.py %PREFIX%/bin/cromwell
if errorlevel 1 exit 1

COPY womtool/womtool-*.jar %outdir%/womtool.jar
if errorlevel 1 exit 1
COPY %RECIPE_DIR%/womtool.py %PREFIX%/bin/womtool
if errorlevel 1 exit 1
