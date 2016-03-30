REM Microsoft Visual Studio Project files from https://github.com/kmanley/snappy-msvc
cp $RECIPE_DIR/snappy.sln $SRC_DIR
cp $RECIPE_DIR/snappy.vcproj $SRC_DIR

set SLN_FILE=snappy.sln
set SLN_CFG=Release
if "%ARCH%"=="32" (set SLN_PLAT=Win32) else (set SLN_PLAT=x64)

REM Build step
devenv "%SLN_FILE%" /Build "%SLN_CFG%|%SLN_PLAT%"
if errorlevel 1 exit 1

