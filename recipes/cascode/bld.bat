@echo off
setlocal EnableExtensions EnableDelayedExpansion

if not exist "%PREFIX%\libexec\%PKG_NAME%" mkdir "%PREFIX%\libexec\%PKG_NAME%"
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

dotnet publish tools\cli\Cascode.Cli.csproj ^
  --no-self-contained ^
  -c Release ^
  -o "%PREFIX%\libexec\%PKG_NAME%"
if errorlevel 1 exit /b 1

REM Keep only runtime assets for conda-forge target platforms.
if exist "%PREFIX%\libexec\%PKG_NAME%\runtimes" (
  pushd "%PREFIX%\libexec\%PKG_NAME%\runtimes"
  for /d %%D in (*) do (
    set "keep=0"
    if /I "%%D"=="linux-x64" set "keep=1"
    if /I "%%D"=="linux-arm64" set "keep=1"
    if /I "%%D"=="osx-x64" set "keep=1"
    if /I "%%D"=="osx-arm64" set "keep=1"
    if /I "%%D"=="win-x64" set "keep=1"
    if "!keep!"=="0" rmdir /s /q "%%D"
  )
  popd
)

if exist "%PREFIX%\libexec\%PKG_NAME%\Cascode.Cli.exe" del /f /q "%PREFIX%\libexec\%PKG_NAME%\Cascode.Cli.exe"
if exist "%PREFIX%\libexec\%PKG_NAME%\Cascode.Cli" del /f /q "%PREFIX%\libexec\%PKG_NAME%\Cascode.Cli"

> "%PREFIX%\Scripts\cascode.cmd" echo @echo off
>> "%PREFIX%\Scripts\cascode.cmd" echo call "%%DOTNET_ROOT%%\dotnet" exec "%%CONDA_PREFIX%%\libexec\cascode\Cascode.Cli.dll" %%*
if errorlevel 1 exit /b 1

