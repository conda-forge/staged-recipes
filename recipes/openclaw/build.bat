@echo on
setlocal enabledelayedexpansion

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
@REM Build native Node addons from source where supported
@REM ============================================================
set npm_config_build_from_source=true
set npm_config_node_gyp=%BUILD_PREFIX%\bin\node-gyp
set NODE_PATH=%BUILD_PREFIX%\node_modules;%NODE_PATH%
set ESBUILD_BINARY_PATH=%BUILD_PREFIX%\bin\esbuild.exe
set PYTHON=%BUILD_PREFIX%\python.exe

call npm install -ddd ^
    --global ^
    --prefix "%PREFIX%" ^
    --build-from-source ^
    "%PKG_NAME%-%PKG_VERSION%.tgz"
if %ERRORLEVEL% neq 0 exit /b 1

@REM ============================================================
@REM Remove non-target platform binaries
@REM ============================================================
set NODE_MODULES=%PREFIX%\node_modules\openclaw\node_modules

set OS=win32
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set ARCH=x64
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set ARCH=arm64
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set ARCH=x64
)

if not defined ARCH (
    echo Unsupported architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

@REM koffi uses OS_ARCH naming and most prebuilds use OS-ARCH.
set KEEP_UNDERSCORE=%OS%_%ARCH%
set KEEP_DASH=%OS%-%ARCH%

echo Pruning foreign binaries, keeping: %KEEP_UNDERSCORE% / %KEEP_DASH%

@REM koffi is no longer installed by current OpenClaw releases, but keep this
@REM guard in case a future transitive dependency reintroduces it.
if exist "%NODE_MODULES%\koffi\build\koffi\" (
    for /d %%d in ("%NODE_MODULES%\koffi\build\koffi\*") do (
        if /i not "%%~nxd"=="%KEEP_UNDERSCORE%" (
            echo Removing koffi: %%d
            rmdir /s /q "%%d"
        )
    )
)
if %ERRORLEVEL% neq 0 exit /b 1

@REM --- prebuilds used by packages such as @lydell/node-pty ---
for /f "delims=" %%p in ('dir "%NODE_MODULES%" /b /s /ad /o:n 2^>nul ^| findstr /i "\\prebuilds$"') do (
    for /d %%d in ("%%p\*") do (
        if /i not "%%~nxd"=="%KEEP_DASH%" (
            echo Removing prebuild: %%d
            rmdir /s /q "%%d"
        )
    )
)
if %ERRORLEVEL% neq 0 exit /b 1

@REM conda-forge should use the locally built tree-sitter-bash binding, not npm prebuilds.
if exist "%NODE_MODULES%\tree-sitter-bash\prebuilds\" (
    rmdir /s /q "%NODE_MODULES%\tree-sitter-bash\prebuilds"
)
if %ERRORLEVEL% neq 0 exit /b 1

@REM Remove tree-sitter-bash build intermediates, keeping the runtime native binding.
if exist "%NODE_MODULES%\tree-sitter-bash\build\Release\" (
    for /d %%d in ("%NODE_MODULES%\tree-sitter-bash\build\Release\*") do (
        rmdir /s /q "%%d"
    )

    for %%f in ("%NODE_MODULES%\tree-sitter-bash\build\Release\*") do (
        if /i not "%%~nxf"=="tree_sitter_bash_binding.node" (
            del /f /q "%%f"
        )
    )
)
if %ERRORLEVEL% neq 0 exit /b 1

@REM --- sqlite-vec platform subpackages ---
set KEEP_DASH_SV=windows-%ARCH%
for /d %%d in ("%NODE_MODULES%\sqlite-vec-*") do (
    if /i not "%%~nxd"=="sqlite-vec-%KEEP_DASH_SV%" (
        echo Removing sqlite-vec subpackage: %%d
        rmdir /s /q "%%d"
    )
)
if %ERRORLEVEL% neq 0 exit /b 1
