@echo on
setlocal EnableExtensions EnableDelayedExpansion

@REM Configure platform defaults
if not defined SHLIB_EXT set "SHLIB_EXT=.dll"
if not defined EXEEXT set "EXEEXT=.exe"

@REM Locate esbuild from the conda build environment
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

@REM Locate wasm-bindgen from the conda build environment
set "WASM_BINDGEN="
if exist "%BUILD_PREFIX%\Library\bin\wasm-bindgen.exe" set "WASM_BINDGEN=%BUILD_PREFIX%\Library\bin\wasm-bindgen.exe"
if not defined WASM_BINDGEN if exist "%BUILD_PREFIX%\bin\wasm-bindgen.exe" set "WASM_BINDGEN=%BUILD_PREFIX%\bin\wasm-bindgen.exe"
if not defined WASM_BINDGEN (
  for /f "delims=" %%I in ('where wasm-bindgen 2^>NUL') do if not defined WASM_BINDGEN set "WASM_BINDGEN=%%~fI"
)
if not defined WASM_BINDGEN (
  echo wasm-bindgen.exe not found
  exit /b 1
)

@REM Configure PyO3 to use the conda host Python
set "PYO3_PYTHON=%PYTHON%"

@REM Generate Rust license metadata for all shipped Rust workspaces
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b !ERRORLEVEL!
pushd python
if errorlevel 1 exit /b !ERRORLEVEL!
cargo-bundle-licenses --format yaml --output ..\THIRDPARTY-python.yml
if errorlevel 1 exit /b !ERRORLEVEL!
popd
pushd web
if errorlevel 1 exit /b !ERRORLEVEL!
cargo-bundle-licenses --format yaml --output ..\THIRDPARTY-web.yml
if errorlevel 1 exit /b !ERRORLEVEL!
popd

@REM Resolve Cargo target and release directories
set "CARGO_ARGS="
if defined CARGO_TARGET_DIR (
  set "TARGET_ROOT=%CARGO_TARGET_DIR%"
) else (
  set "TARGET_ROOT=target"
)
set "RELEASE_DIR=%TARGET_ROOT%\release"

if defined CARGO_BUILD_TARGET (
  set "CARGO_ARGS=--target %CARGO_BUILD_TARGET%"
  set "RELEASE_DIR=%TARGET_ROOT%\%CARGO_BUILD_TARGET%\release"
)

@REM Build the native desktop binary and native plugins with auditable metadata
cargo auditable build --release --locked %CARGO_ARGS% ^
  -p patinae ^
  -p raytracer-plugin ^
  -p hello-plugin ^
  -p ipc-plugin ^
  -p python-plugin
if errorlevel 1 exit /b !ERRORLEVEL!

@REM Install the native desktop binary under libexec
if not exist "%PREFIX%\libexec\patinae\bin" mkdir "%PREFIX%\libexec\patinae\bin"

copy /Y "%RELEASE_DIR%\patinae%EXEEXT%" "%PREFIX%\libexec\patinae\bin\patinae%EXEEXT%"
if errorlevel 1 exit /b !ERRORLEVEL!

@REM Install native plugin libraries under libexec
if not exist "%PREFIX%\libexec\patinae\plugins" mkdir "%PREFIX%\libexec\patinae\plugins"

set "PLUGIN_COUNT=0"
for %%F in ("%RELEASE_DIR%\*_plugin%SHLIB_EXT%") do (
  if exist "%%~fF" (
    copy /Y "%%~fF" "%PREFIX%\libexec\patinae\plugins\"
    if errorlevel 1 exit /b !ERRORLEVEL!
    set /A PLUGIN_COUNT+=1
  )
)

if "!PLUGIN_COUNT!"=="0" (
  echo No plugin libraries found in %RELEASE_DIR%
  dir /S /B "%TARGET_ROOT%\*_plugin%SHLIB_EXT%" 2>NUL
  exit /b 1
)

@REM Prepare web dependencies and JavaScript license metadata
pushd web
if errorlevel 1 exit /b !ERRORLEVEL!

@REM NOTE: web/package.json currently has no production dependencies, so this
@REM condition is expected to be false and keep an empty file. Keep the guard
@REM for forward-compatibility if upstream adds runtime web dependencies later.
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

@REM Install full web build dependencies without running package scripts
if exist node_modules rmdir /S /Q node_modules

call pnpm import
if errorlevel 1 exit /b !ERRORLEVEL!

call pnpm install --ignore-scripts --frozen-lockfile
if errorlevel 1 exit /b !ERRORLEVEL!

@REM Build the WebAssembly viewer without inheriting native Rust linker flags
@REM NOTE: wasm-pack is intentionally not used here. wasm-pack always attempts
@REM to download a matching wasm-bindgen binary at build time, which fails in
@REM the network-isolated conda-forge build environment. wasm-bindgen-cli is
@REM already installed as a build dependency, so cargo and wasm-bindgen are
@REM invoked directly instead.
setlocal
set "RUSTFLAGS="
set "CARGO_ENCODED_RUSTFLAGS="
set "CARGO_BUILD_RUSTFLAGS="
set "CARGO_BUILD_TARGET="
set "LDFLAGS="
set "CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_RUSTFLAGS="
set "CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER="

set "WASM_TARGET_ROOT=target"
if defined CARGO_TARGET_DIR set "WASM_TARGET_ROOT=%CARGO_TARGET_DIR%"

cargo build --release --locked --target wasm32-unknown-unknown -p patinae-web
if errorlevel 1 (
  endlocal
  exit /b 1
)

if not exist pkg mkdir pkg
call "%WASM_BINDGEN%" --target web --out-dir pkg --no-typescript "%WASM_TARGET_ROOT%\wasm32-unknown-unknown\release\patinae_web.wasm"
set "WASM_STATUS=%ERRORLEVEL%"
endlocal & if not "%WASM_STATUS%"=="0" exit /b %WASM_STATUS%

@REM Bundle the web viewer assets with Vite
call pnpm exec vite build
if errorlevel 1 exit /b !ERRORLEVEL!

popd

@REM Copy web viewer assets into the Python widget package
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

@REM Build and install the Python extension wheel
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

@REM Replace the Python `patinae` entry point with non-conflicting wrappers
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

del /F /Q ^
  "%PREFIX%\Scripts\patinae.exe" ^
  "%PREFIX%\Scripts\patinae-script.py" ^
  "%PREFIX%\Scripts\patinae.bat" ^
  "%PREFIX%\Scripts\patinae.cmd" ^
  "%PREFIX%\Scripts\patinae-cli.bat" ^
  "%PREFIX%\Scripts\patinae-cli.cmd" 2>NUL

@REM Keep the Python console entry point as `patinae-cli`
> "%PREFIX%\Scripts\patinae-cli.bat" echo @echo off
>> "%PREFIX%\Scripts\patinae-cli.bat" echo set "SCRIPT_DIR=%%~dp0"
>> "%PREFIX%\Scripts\patinae-cli.bat" echo "%%SCRIPT_DIR%%..\python.exe" -m patinae._cli %%*
>> "%PREFIX%\Scripts\patinae-cli.bat" echo exit /b %%ERRORLEVEL%%

@REM Install the user-facing desktop wrapper as `patinae`
> "%PREFIX%\Scripts\patinae.bat" echo @echo off
>> "%PREFIX%\Scripts\patinae.bat" echo setlocal
>> "%PREFIX%\Scripts\patinae.bat" echo set "SCRIPT_DIR=%%~dp0"
>> "%PREFIX%\Scripts\patinae.bat" echo set "PREFIX_DIR=%%SCRIPT_DIR%%.."
>> "%PREFIX%\Scripts\patinae.bat" echo if not defined PATINAE_PLUGIN_DIR set "PATINAE_PLUGIN_DIR=%%PREFIX_DIR%%\libexec\patinae\plugins"
>> "%PREFIX%\Scripts\patinae.bat" echo "%%PREFIX_DIR%%\libexec\patinae\bin\patinae.exe" %%*
>> "%PREFIX%\Scripts\patinae.bat" echo exit /b %%ERRORLEVEL%%

@REM Register a menuinst desktop shortcut so the installed icon launches the
@REM `patinae` wrapper (and thus picks up PATINAE_PLUGIN_DIR) rather than the
@REM raw libexec binary.
if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
powershell -Command "(Get-Content '%RECIPE_DIR%\menu.json') -replace '__PKG_VERSION__', '%PKG_VERSION%' | Set-Content '%PREFIX%\Menu\patinae_menu.json'"
if errorlevel 1 exit /b !ERRORLEVEL!
copy /Y "%SRC_DIR%\images\patinae.png" "%PREFIX%\Menu\patinae.png"
if errorlevel 1 exit /b !ERRORLEVEL!
copy /Y "%SRC_DIR%\images\patinae.ico" "%PREFIX%\Menu\patinae.ico"
if errorlevel 1 exit /b !ERRORLEVEL!

exit /b 0
