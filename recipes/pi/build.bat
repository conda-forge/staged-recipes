@echo off
setlocal enableextensions

:: Repack the extracted package into a tarball, then install that tarball into the
:: prefix. Installing from a tarball (rather than the unpacked folder) makes npm
:: resolve and install the full dependency tree pinned by npm-shrinkwrap.json,
:: including the sibling @earendil-works/pi-{ai,agent-core,tui} packages and the
:: vendored prebuilt native addons.
mkdir "%SRC_DIR%\packed" 2>nul
pushd "%SRC_DIR%\app"
call npm pack --pack-destination "%SRC_DIR%\packed"
if errorlevel 1 ( popd & exit /b 1 )
popd
for /f "delims=" %%t in ('dir /b "%SRC_DIR%\packed\*.tgz"') do set "TGZ=%SRC_DIR%\packed\%%t"
call npm install -g --prefix "%PREFIX%" "%TGZ%"
if errorlevel 1 exit /b 1

:: pi-tui's npm package bundles prebuilt native addons for every OS/arch. Keep
:: only the prebuild matching this target platform and drop the rest.
set "KEEP=win32-x64"
if /i "%target_platform%"=="win-arm64" set "KEEP=win32-arm64"

set "PI_TUI="
for /f "delims=" %%d in ('dir /b /s /a:d "%PREFIX%\node_modules" 2^>nul ^| findstr /e "\\@earendil-works\\pi-tui"') do set "PI_TUI=%%d"
if defined PI_TUI (
  rmdir /s /q "%PI_TUI%\native\darwin" 2>nul
  for /d %%a in ("%PI_TUI%\native\win32\prebuilds\*") do (
    if /i not "%%~nxa"=="%KEEP%" rmdir /s /q "%%a" 2>nul
  )
)
