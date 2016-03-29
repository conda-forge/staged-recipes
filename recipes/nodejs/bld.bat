if "%ARCH%"=="32" (
   set PLATFORM=x86
) else (
  set PLATFORM=x64
)

vcbuild.bat nosign release %PLATFORM%

COPY Release\node.exe %LIBRARY_BIN%\node.exe

curl -LO https://github.com/npm/npm/archive/v3.7.1.zip
7za x v3.7.1.zip

mkdir "%LIBRARY_BIN%\node_modules"
mkdir "%LIBRARY_BIN%\node_modules\npm"
ROBOCOPY npm-3.7.1\ "%LIBRARY_BIN%\node_modules\npm" * /E
COPY npm-3.7.1\bin\npm.cmd "%LIBRARY_BIN%\npm.cmd"

if %ERRORLEVEL% LSS 8 exit 0
