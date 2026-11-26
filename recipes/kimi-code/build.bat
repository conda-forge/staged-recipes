@echo on

@rem Remove upstream prebuilt native addons before building from source
rmdir /s /q packages\pi-tui\native\darwin\prebuilds
rmdir /s /q packages\pi-tui\native\linux\prebuilds
rmdir /s /q packages\pi-tui\native\win32\prebuilds

set "NATIVE_ARCH=x64"
if "%target_platform%"=="win-arm64" set "NATIVE_ARCH=arm64"

set "INSTALL_DIR=%LIBRARY_PREFIX%\share\kimi-code"
set "NATIVE_DIR=%INSTALL_DIR%\native\win32\prebuilds\win32-%NATIVE_ARCH%"
mkdir "%NATIVE_DIR%"
if errorlevel 1 exit 1

cl /nologo /TC /std:c11 /W4 /O1 /GS- /LD ^
    /Fe:"%NATIVE_DIR%\win32-platform.node" ^
    packages\pi-tui\native\win32\src\win32-platform.c ^
    /link /NOENTRY /NODEFAULTLIB kernel32.lib user32.lib /OPT:REF /OPT:ICF
if errorlevel 1 exit 1

set "npm_config_minimum_release_age=0"
set "pnpm_config_strict_dep_builds=false"
set "pnpm_config_manage_package_manager_versions=false"
set "pnpm_config_ignore_workspace_cycles=true"

call pnpm install --frozen-lockfile --ignore-scripts
if errorlevel 1 exit 1

call pnpm -r --filter "./packages/*" run build
if errorlevel 1 exit 1

@rem Run prebuild steps directly because sync-web-dist.mjs hardcodes pnpm.cmd (conda-forge ships pnpm.exe)
node apps\kimi-code\scripts\build-vis-asset.mjs
if errorlevel 1 exit 1

call pnpm --filter kimi-code-app run build:web
if errorlevel 1 exit 1

xcopy /e /i /y apps\desktop\web-dist apps\kimi-code\dist-web
if errorlevel 1 exit 1

call pnpm --filter @moonshot-ai/kimi-code exec tsdown
if errorlevel 1 exit 1

call pnpm --filter @moonshot-ai/kimi-code exec tsdown --config tsdown.dist-worker.config.ts
if errorlevel 1 exit 1

node apps\kimi-code\scripts\check-web-assets.mjs
if errorlevel 1 exit 1

copy apps\kimi-code\package.json "%INSTALL_DIR%\package.json"
if errorlevel 1 exit 1
xcopy /e /i /y apps\kimi-code\dist "%INSTALL_DIR%\dist"
if errorlevel 1 exit 1
xcopy /e /i /y apps\kimi-code\dist-web "%INSTALL_DIR%\dist-web"
if errorlevel 1 exit 1
copy LICENSE "%INSTALL_DIR%\LICENSE"
if errorlevel 1 exit 1

if not exist "%LIBRARY_PREFIX%\bin" mkdir "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1
(
  echo @echo off
  echo call node "%%~dp0..\share\kimi-code\dist\main.mjs" %%*
) > "%LIBRARY_PREFIX%\bin\kimi.cmd"
if errorlevel 1 exit 1

call pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt
if errorlevel 1 exit 1
