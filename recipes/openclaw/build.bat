@echo on
setlocal enabledelayedexpansion

@REM ============================================================
@REM Sharp: ignore global libvips (initial build phase)
@REM ============================================================
set SHARP_IGNORE_GLOBAL_LIBVIPS=1
set npm_config_sharp_ignore_global_libvips=true

@REM ============================================================
@REM Patch minimumReleaseAge in pnpm-workspace.yaml
@REM ============================================================
sed -i.bak "s/^minimumReleaseAge: .*/minimumReleaseAge: 0/" pnpm-workspace.yaml
if %ERRORLEVEL% neq 0 exit /b 1

@REM ============================================================
@REM License report for dependencies
@REM ============================================================
copy /y package.json package.json.bak
if %ERRORLEVEL% neq 0 exit /b 1

jq "del(.devDependencies)" package.json.bak > package.json
if %ERRORLEVEL% neq 0 exit /b 1

call pnpm install --prod
if %ERRORLEVEL% neq 0 exit /b 1

call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if %ERRORLEVEL% neq 0 exit /b 1

move /y package.json.bak package.json
if %ERRORLEVEL% neq 0 exit /b 1

rmdir /s /q node_modules
if %ERRORLEVEL% neq 0 exit /b 1

@REM ============================================================
@REM Build and pack
@REM ============================================================
call pnpm install
if %ERRORLEVEL% neq 0 exit /b 1

call pnpm build
if %ERRORLEVEL% neq 0 exit /b 1

call pnpm ui:build
if %ERRORLEVEL% neq 0 exit /b 1

call pnpm pack --config.ignore-scripts=true
if %ERRORLEVEL% neq 0 exit /b 1

@REM ============================================================
@REM Sharp: use conda-forge libvips, build native binding
@REM ============================================================
set SHARP_IGNORE_GLOBAL_LIBVIPS=
set npm_config_sharp_ignore_global_libvips=
set SHARP_FORCE_GLOBAL_LIBVIPS=1
set npm_config_sharp_build_from_source=true
set npm_config_sharp_force_global_libvips=true
set npm_config_build_from_source=true
set npm_config_node_gyp=%BUILD_PREFIX%\bin\node-gyp
set NODE_PATH=%BUILD_PREFIX%\lib\node_modules;%NODE_PATH%
set ESBUILD_BINARY_PATH=%BUILD_PREFIX%\bin\esbuild.exe
set PYTHON=%BUILD_PREFIX%\python.exe
set PKG_CONFIG_PATH=%PREFIX%\lib\pkgconfig;%PREFIX%\share\pkgconfig;%PKG_CONFIG_PATH%

for /f "tokens=*" %%i in ('pkg-config --cflags vips-cpp') do set VIPS_CFLAGS=%%i
for /f "tokens=*" %%i in ('pkg-config --libs vips-cpp') do set VIPS_LIBS=%%i
set CPPFLAGS=%VIPS_CFLAGS% %CPPFLAGS%
set CXXFLAGS=%VIPS_CFLAGS% %CXXFLAGS%
set LDFLAGS=%VIPS_LIBS% %LDFLAGS%

call npm install -ddd ^
    --global ^
    --prefix "%PREFIX%" ^
    --build-from-source ^
    %PKG_NAME%-%PKG_VERSION%.tgz
if %ERRORLEVEL% neq 0 exit /b 1

set NODE_MODULES=%PREFIX%\lib\node_modules\openclaw\node_modules

set OS=win32
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set ARCH=x64
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set ARCH=arm64
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set ARCH=x64
)

set KEEP_UNDERSCORE=%OS%_%ARCH%
set KEEP_DASH=%OS%-%ARCH%

echo Pruning foreign binaries, keeping: %KEEP_UNDERSCORE% / %KEEP_DASH%

@REM --- koffi ---
for /d %%d in ("%NODE_MODULES%\koffi\build\koffi\*") do (
    if /i not "%%~nxd"=="%KEEP_UNDERSCORE%" (
        echo Removing koffi: %%d
        rmdir /s /q "%%d"
    )
)

@REM --- prebuilds (tree-sitter etc...) ---
powershell -Command "Get-ChildItem -Path '%NODE_MODULES%' -Recurse -Directory -Filter 'prebuilds' | ForEach-Object { Get-ChildItem -Path $_.FullName -Directory | Where-Object { $_.Name -ne '%KEEP_DASH%' } | ForEach-Object { Write-Host ('Removing prebuild: ' + $_.FullName); Remove-Item -Recurse -Force $_.FullName } }"
if %ERRORLEVEL% neq 0 exit /b 1
