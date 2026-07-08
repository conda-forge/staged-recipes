@echo on
setlocal EnableExtensions EnableDelayedExpansion

if not defined SHLIB_EXT set "SHLIB_EXT=.dll"
if not defined EXEEXT set "EXEEXT=.exe"

set "ESBUILD_BINARY_PATH="
if exist "%BUILD_PREFIX%\Library\bin\esbuild.exe" set "ESBUILD_BINARY_PATH=%BUILD_PREFIX%\Library\bin\esbuild.exe"
if not defined ESBUILD_BINARY_PATH if exist "%BUILD_PREFIX%\bin\esbuild.exe" set "ESBUILD_BINARY_PATH=%BUILD_PREFIX%\bin\esbuild.exe"
if not defined ESBUILD_BINARY_PATH (
  for /f "delims=" %%I in ('where esbuild 2^>NUL') do if not defined ESBUILD_BINARY_PATH set "ESBUILD_BINARY_PATH=%%~fI"
)
if not defined ESBUILD_BINARY_PATH (
  echo esbuild.exe not found
  exit /b 1
)

set "WASM_PACK="
if exist "%BUILD_PREFIX%\Library\bin\wasm-pack.exe" set "WASM_PACK=%BUILD_PREFIX%\Library\bin\wasm-pack.exe"
if not defined WASM_PACK if exist "%BUILD_PREFIX%\bin\wasm-pack.exe" set "WASM_PACK=%BUILD_PREFIX%\bin\wasm-pack.exe"
if not defined WASM_PACK (
  for /f "delims=" %%I in ('where wasm-pack 2^>NUL') do if not defined WASM_PACK set "WASM_PACK=%%~fI"
)
if not defined WASM_PACK (
  echo wasm-pack.exe not found
  exit /b 1
)

set "PYO3_PYTHON=%PYTHON%"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b !ERRORLEVEL!

cargo install --locked --root "%PREFIX%\libexec\patinae" --path patinae
if errorlevel 1 exit /b !ERRORLEVEL!

del /F /Q "%PREFIX%\libexec\patinae\.crates.toml" "%PREFIX%\libexec\patinae\.crates2.json" 2>NUL

set "CARGO_ARGS="
if defined CARGO_TARGET_DIR (
  set "TARGET_ROOT=%CARGO_TARGET_DIR%"
) else (
  set "TARGET_ROOT=target"
)
set "PLUGIN_RELEASE_DIR=%TARGET_ROOT%\release"

if defined CARGO_BUILD_TARGET (
  set "CARGO_ARGS=--target %CARGO_BUILD_TARGET%"
  set "PLUGIN_RELEASE_DIR=%TARGET_ROOT%\%CARGO_BUILD_TARGET%\release"
)

cargo build --release --locked --lib %CARGO_ARGS% ^
  -p raytracer-plugin ^
  -p hello-plugin ^
  -p ipc-plugin ^
  -p python-plugin
if errorlevel 1 exit /b !ERRORLEVEL!

if not exist "%PREFIX%\libexec\patinae\plugins" mkdir "%PREFIX%\libexec\patinae\plugins"

set "PLUGIN_COUNT=0"
for %%F in ("%PLUGIN_RELEASE_DIR%\*_plugin%SHLIB_EXT%") do (
  if exist "%%~fF" (
    copy /Y "%%~fF" "%PREFIX%\libexec\patinae\plugins\"
    if errorlevel 1 exit /b !ERRORLEVEL!
    set /A PLUGIN_COUNT+=1
  )
)

if "!PLUGIN_COUNT!"=="0" (
  echo No plugin libraries found in %PLUGIN_RELEASE_DIR%
  dir /S /B "%TARGET_ROOT%\*_plugin%SHLIB_EXT%" 2>NUL
  exit /b 1
)

pushd web
if errorlevel 1 exit /b !ERRORLEVEL!

jq -e "((.dependencies // {}) + (.optionalDependencies // {})) | length > 0" package.json >NUL
if errorlevel 1 (
  echo No production npm dependencies; creating empty third-party-licenses.txt
  type nul > third-party-licenses.txt
) else (
  call pnpm install --prod --ignore-scripts
  if errorlevel 1 exit /b !ERRORLEVEL!
  call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
  if errorlevel 1 exit /b !ERRORLEVEL!
)

if exist node_modules rmdir /S /Q node_modules

call pnpm install --ignore-scripts --no-frozen-lockfile
if errorlevel 1 exit /b !ERRORLEVEL!

setlocal
set "RUSTFLAGS="
set "CARGO_ENCODED_RUSTFLAGS="
set "CARGO_BUILD_RUSTFLAGS="
set "CARGO_BUILD_TARGET="
set "LDFLAGS="
set "CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_RUSTFLAGS="
set "CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER="
call "%WASM_PACK%" build --target web --out-dir pkg --no-opt
set "WASM_STATUS=%ERRORLEVEL%"
endlocal & if not "%WASM_STATUS%"=="0" exit /b %WASM_STATUS%

call pnpm exec vite build
if errorlevel 1 exit /b !ERRORLEVEL!

popd

if not exist "python\patinae\widget\static" mkdir "python\patinae\widget\static"

copy /Y "web\dist\patinae-viewer.js" "python\patinae\widget\static\"
if errorlevel 1 exit /b !ERRORLEVEL!

copy /Y "web\dist\patinae_web_bg.wasm" "python\patinae\widget\static\"
if errorlevel 1 exit /b !ERRORLEVEL!

set "GLUE_FILE="
for %%F in ("web\dist\patinae_web-*.js") do (
  if exist "%%~fF" (
    if defined GLUE_FILE (
      echo Expected exactly one wasm glue JS file
      dir /B "web\dist\patinae_web-*.js"
      exit /b 1
    )
    set "GLUE_FILE=%%~fF"
  )
)

if not defined GLUE_FILE (
  echo No wasm glue JS file found
  exit /b 1
)

copy /Y "!GLUE_FILE!" "python\patinae\widget\static\patinae_web_glue.js"
if errorlevel 1 exit /b !ERRORLEVEL!

maturin build --release ^
  --manifest-path python\Cargo.toml ^
  --interpreter "%PYTHON%" ^
  --out wheels
if errorlevel 1 exit /b !ERRORLEVEL!

set "WHEEL="
for %%F in ("wheels\patinae-*.whl") do (
  if exist "%%~fF" set "WHEEL=%%~fF"
)

if not defined WHEEL (
  echo No patinae wheel found
  exit /b 1
)

"%PYTHON%" -m pip install --no-deps -vv "!WHEEL!"
if errorlevel 1 exit /b !ERRORLEVEL!

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

del /F /Q ^
  "%PREFIX%\Scripts\patinae.exe" ^
  "%PREFIX%\Scripts\patinae-script.py" ^
  "%PREFIX%\Scripts\patinae.bat" ^
  "%PREFIX%\Scripts\patinae.cmd" 2>NUL

> "%PREFIX%\Scripts\patinae.bat" echo @echo off
>> "%PREFIX%\Scripts\patinae.bat" echo setlocal
>> "%PREFIX%\Scripts\patinae.bat" echo for %%%%I in ^("%%~dp0.."^) do set "prefix=%%%%~fI"
>> "%PREFIX%\Scripts\patinae.bat" echo if not defined PATINAE_PLUGIN_DIR set "PATINAE_PLUGIN_DIR=%%prefix%%\libexec\patinae\plugins"
>> "%PREFIX%\Scripts\patinae.bat" echo "%%prefix%%\libexec\patinae\bin\patinae.exe" %%*
>> "%PREFIX%\Scripts\patinae.bat" echo exit /b %%ERRORLEVEL%%

exit /b 0
