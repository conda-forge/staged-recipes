@echo off
setlocal enabledelayedexpansion

echo === Build environment ===
node --version
if errorlevel 1 exit /b 1
:: pnpm ships as pnpm.cmd; bare-invoke would transfer control and terminate
:: this script. Always use `call pnpm ...`. Same for any other .cmd shim.
call pnpm --version
if errorlevel 1 exit /b 1
rustc --version
if errorlevel 1 exit /b 1
cargo --version
if errorlevel 1 exit /b 1

set NODE_OPTIONS=--max-old-space-size=6144

echo === Installing JS workspace dependencies ===
call pnpm install --frozen-lockfile --strict-peer-dependencies=false
if errorlevel 1 exit /b 1

echo === Generating Rust third-party license inventory ===
pushd src-tauri
call cargo-bundle-licenses --format yaml --output ..\THIRDPARTY-RUST.yml
if errorlevel 1 exit /b 1
popd

echo === Generating npm third-party license disclaimer ===
call pnpm licenses list --prod --long > THIRDPARTY-NPM.txt
if errorlevel 1 exit /b 1

if not exist LICENSE exit /b 1
if not exist THIRDPARTY-RUST.yml exit /b 1
if not exist THIRDPARTY-NPM.txt exit /b 1

echo === Windows x64 build (raw binary) ===
:: --no-bundle: produce only target\release\tolaria.exe, skip MSI/NSIS
:: bundlers (which would be repackaged out of conda's prefix layout anyway).
call pnpm tauri build --no-bundle --config "{\"bundle\":{\"createUpdaterArtifacts\":false}}"
if errorlevel 1 exit /b 1

:: Conda-forge's rust compiler activation passes --target=<triple>, so cargo
:: outputs to target\<triple>\release\ instead of target\release\.
set BIN_SRC=src-tauri\target\x86_64-pc-windows-msvc\release\tolaria.exe
if not exist "%BIN_SRC%" set BIN_SRC=src-tauri\target\release\tolaria.exe
if not exist "%BIN_SRC%" (
  echo ERROR: tolaria.exe not produced by tauri build
  exit /b 1
)

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
copy /Y "%BIN_SRC%" "%LIBRARY_BIN%\tolaria.exe"
if errorlevel 1 exit /b 1

:: Tauri's webview2-com-sys vendors WebView2Loader.dll alongside the binary
:: at build time. Copy if present (resolves to the same dir as the .exe).
for %%D in ("src-tauri\target\x86_64-pc-windows-msvc\release" "src-tauri\target\release") do (
  if exist "%%~D\WebView2Loader.dll" (
    copy /Y "%%~D\WebView2Loader.dll" "%LIBRARY_BIN%\WebView2Loader.dll"
    if errorlevel 1 exit /b 1
    goto :webview_copied
  )
)
:webview_copied

:: Stage MCP server resources at Tauri's expected runtime location.
:: tauri::path::resource_dir() on Windows checks <exe_dir>\resources\ first.
if not exist "%LIBRARY_BIN%\resources" mkdir "%LIBRARY_BIN%\resources"
xcopy /E /I /Q /Y src-tauri\resources\mcp-server "%LIBRARY_BIN%\resources\mcp-server\"
if errorlevel 1 exit /b 1

:: menuinst manifest + icon
if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
copy /Y "%RECIPE_DIR%\tolaria-menu.json" "%PREFIX%\Menu\tolaria-menu.json"
if errorlevel 1 exit /b 1
copy /Y src-tauri\icons\icon.ico "%PREFIX%\Menu\tolaria.ico"
if errorlevel 1 exit /b 1

echo === Build complete ===
