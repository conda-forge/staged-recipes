@echo on
setlocal enabledelayedexpansion

:: Currently the recipe `skip:` clause excludes Windows. This script is in
:: place so the recipe is portable when win-64 is enabled.

if "%SRC_DIR%"=="" set "SRC_DIR=%CD%"
cd /d "%SRC_DIR%"
if errorlevel 1 exit /b 1

echo === Build environment ===
echo SRC_ROOT: %SRC_DIR%
echo PREFIX:   %PREFIX%
echo LIBRARY_BIN: %LIBRARY_BIN%

:: --- pnpm via corepack ----------------------------------------------------
:: Per repo convention: every .cmd shim must be invoked with `call`, otherwise
:: cmd.exe transfers control and the parent script exits silently.
set "COREPACK_HOME=%SRC_DIR%\.corepack"
call corepack enable --install-directory "%BUILD_PREFIX%\Scripts"
if errorlevel 1 exit /b 1
call corepack prepare pnpm@10.33.2 --activate
if errorlevel 1 exit /b 1
call pnpm --version
if errorlevel 1 exit /b 1

set "NODE_OPTIONS=--max-old-space-size=4096"
set "NEXU_OPEN_DESIGN_BUILD=conda"

:: --- filtered install -----------------------------------------------------
call pnpm install --frozen-lockfile --strict-peer-dependencies=false --filter "@open-design/daemon..."
if errorlevel 1 exit /b 1

call pnpm --filter "@open-design/daemon..." run build
if errorlevel 1 exit /b 1

:: --- third-party licenses -------------------------------------------------
call pnpm --filter "@open-design/daemon" licenses list --prod --long > "%SRC_DIR%\ThirdPartyNotices.txt"
if errorlevel 1 (
    echo WARNING: license enumeration failed; writing placeholder
    echo Third-party license texts could not be enumerated automatically. > "%SRC_DIR%\ThirdPartyNotices.txt"
)

:: --- stage to PREFIX ------------------------------------------------------
set "INSTALL_DIR=%PREFIX%\Library\lib\open-design"
mkdir "%INSTALL_DIR%\apps\daemon"           2>nul
mkdir "%INSTALL_DIR%\packages\contracts"    2>nul
mkdir "%INSTALL_DIR%\packages\platform"     2>nul
mkdir "%INSTALL_DIR%\packages\sidecar"      2>nul
mkdir "%INSTALL_DIR%\packages\sidecar-proto" 2>nul

xcopy /E /I /Y apps\daemon\dist          "%INSTALL_DIR%\apps\daemon\dist"
copy  /Y apps\daemon\package.json        "%INSTALL_DIR%\apps\daemon\package.json"
for %%P in (contracts platform sidecar sidecar-proto) do (
    xcopy /E /I /Y packages\%%P\dist     "%INSTALL_DIR%\packages\%%P\dist"
    copy  /Y packages\%%P\package.json   "%INSTALL_DIR%\packages\%%P\package.json"
)
xcopy /E /I /Y node_modules              "%INSTALL_DIR%\node_modules"
copy  /Y package.json                    "%INSTALL_DIR%\package.json"
copy  /Y pnpm-workspace.yaml             "%INSTALL_DIR%\pnpm-workspace.yaml"

:: --- launcher (od.cmd) ----------------------------------------------------
mkdir "%LIBRARY_BIN%" 2>nul
> "%LIBRARY_BIN%\od.cmd" (
    echo @echo off
    echo node "%%~dp0..\lib\open-design\apps\daemon\dist\cli.js" %%*
)

echo === Install complete ===
dir "%LIBRARY_BIN%\od.cmd"
endlocal
