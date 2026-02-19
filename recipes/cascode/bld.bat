@echo off
setlocal enabledelayedexpansion

REM Map target_platform to .NET RID
if "%target_platform%"=="win-64" (
    set "rid=win-x64"
) else if "%target_platform%"=="win-arm64" (
    set "rid=win-arm64"
) else (
    echo Unsupported target_platform: %target_platform% 1>&2
    exit /b 1
)

REM Framework-dependent build
dotnet publish tools\cli\Cascode.Cli.csproj ^
    -c Release ^
    -r %rid% ^
    -p:SelfContained=false ^
    -p:PublishTrimmed=false ^
    -o build\out
if errorlevel 1 exit /b 1

REM Install application files to Library\cascode
mkdir "%PREFIX%\Library\cascode"
xcopy /E /I /Y build\out\* "%PREFIX%\Library\cascode\"
if errorlevel 1 exit /b 1

REM Create wrapper script in Scripts
mkdir "%PREFIX%\Scripts"
echo @echo off > "%PREFIX%\Scripts\cascode.cmd"
echo "%%~dp0\..\Library\cascode\Cascode.Cli.exe" %%* >> "%PREFIX%\Scripts\cascode.cmd"
if errorlevel 1 exit /b 1
