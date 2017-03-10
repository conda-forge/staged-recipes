:: Configure
set CONF=Release
if "%ARCH%" == "64" (
  set ARCH=x64
) else (
  set ARCH=Win32
)

set SLN_FILE=zstd.sln

if "%VS_YEAR%" == "2008" (
  set TOOLSET=v90
  set SLN_DIR=%SRC_DIR%\build\VS2008
  set OUTPUT_DIR=%SRC_DIR%\build\VS2008\bin\%ARCH%\%CONF%
)
if "%VS_YEAR%" == "2015" (
  set TOOLSET=v140
  set SLN_DIR=%SRC_DIR%\build\VS2010
  set OUTPUT_DIR=%SRC_DIR%\build\VS2010\bin\%ARCH%_%CONF%
)
if "%VS_YEAR%" == "" (
  echo Unknown VS version
  exit 1
)

cd %SLN_DIR% || exit 1
call devenv %SLN_FILE% /Upgrade

:: Build
msbuild %SLN_FILE% ^
  /t:Build /v:minimal ^
  /p:Configuration=%CONF% ^
  /p:Platform=%ARCH% ^
  /p:PlatformToolset=%TOOLSET% ^
  /p:SolutionDir=%SLN_DIR%\ ^
  /p:OutDir=%OUTPUT_DIR%\
if errorlevel 1 exit 1

dir /s /b

:: Install
copy %OUTPUT_DIR%\zstd.exe %LIBRARY_BIN% || exit 1

if "%VS_YEAR%" == "2015" (
  copy %OUTPUT_DIR%\libzstd.dll %LIBRARY_LIB% || exit 1
  copy %OUTPUT_DIR%\libzstd.lib %LIBRARY_LIB% || exit 1
  copy %OUTPUT_DIR%\libzstd_static.lib %LIBRARY_LIB% || exit 1
)
if "%VS_YEAR%" == "2008" (
  copy %OUTPUT_DIR%\zstdlib.dll %LIBRARY_LIB%\libzstd.dll || exit 1
  copy %OUTPUT_DIR%\zstdlib.lib %LIBRARY_LIB%\libzstd.lib || exit 1
)

copy %SRC_DIR%\lib\dll\libzstd.def %LIBRARY_LIB% || exit 1
copy %SRC_DIR%\lib\zstd.h %LIBRARY_INC% || exit 1
