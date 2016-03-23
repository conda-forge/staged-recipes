cd %SRC_DIR%
git clone https://github.com/kmanley/snappy-msvc
cd snappy-msvc

set SLN_FILE=snappy.sln
set SLN_CFG=Release
if "%ARCH%"=="32" (set SLN_PLAT=Win32) else (set SLN_PLAT=x64)

REM Build step
devenv "%SLN_FILE%" /Build "%SLN_CFG%|%SLN_PLAT%"
if errorlevel 1 exit 1

