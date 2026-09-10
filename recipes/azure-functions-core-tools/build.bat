@echo on

set "RID=win-x64"
set "NUGET_PACKAGES=%SRC_DIR%\.nuget\packages"
set "PUBLISH_DIR=%SRC_DIR%\out\conda\%RID%"

dotnet restore src\Cli\func\Azure.Functions.Cli.csproj ^
  --runtime %RID% ^
  --configfile NuGet.Config ^
  -p:NuGetAudit=false
if errorlevel 1 exit /b 1

dotnet publish src\Cli\func\Azure.Functions.Cli.csproj ^
  --configuration Release ^
  --framework net10.0 ^
  --runtime %RID% ^
  --self-contained ^
  --no-restore ^
  -p:TemplatesJsonZip="%SRC_DIR%\templates.zip" ^
  -p:Version="%PKG_VERSION%" ^
  --output "%PUBLISH_DIR%"
if errorlevel 1 exit /b 1

set "APPDIR=%LIBRARY_PREFIX%\libexec\azure-functions-core-tools"
if not exist "%APPDIR%" mkdir "%APPDIR%"
xcopy /E /I /Y "%PUBLISH_DIR%\*" "%APPDIR%\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
(
  echo @echo off
  echo "%%~dp0..\Library\libexec\azure-functions-core-tools\func.exe" %%*
) > "%PREFIX%\Scripts\func.cmd"
if errorlevel 1 exit /b 1
