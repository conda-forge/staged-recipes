@echo off
setlocal enabledelayedexpansion

echo === Build environment ===
echo LIBRARY_PREFIX: %LIBRARY_PREFIX%
echo SCRIPTS: %SCRIPTS%
echo PWD: %CD%

:: Display Node version
node --version
if errorlevel 1 exit /b 1

echo === Setting up pnpm via corepack ===
:: Enable corepack (bundled with Node.js 24+)
call corepack enable
if errorlevel 1 exit /b 1

:: Prepare specific pnpm version used by Podman Desktop
call corepack prepare pnpm@10.20.0 --activate
if errorlevel 1 exit /b 1

:: Verify pnpm is available
call pnpm --version
if errorlevel 1 exit /b 1

echo === Configuring build environment ===
:: Set memory limit for Vite renderer build (requires 6GB)
set NODE_OPTIONS=--max-old-space-size=6144

:: Disable code signing (conda builds don't need app store signing)
set CSC_IDENTITY_AUTO_DISCOVERY=false
set WIN_CSC_LINK=

:: Disable auto-update (not applicable for conda packages)
set PUBLISH_FOR_UPDATES=false

:: Disable electron-builder publishing
set ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES=true
set CI=false
set GH_TOKEN=
set EP_PRE_RELEASE=false

:: Configure node-gyp to use conda's compilers and VS Build Tools
set npm_config_msvs_version=2022
set GYP_MSVS_VERSION=2022
:: Use distutils for Python (node-gyp compatibility)
set SETUPTOOLS_USE_DISTUTILS=stdlib

:: Skip native module rebuild (electron-rebuild fails on Electron 39.2.6)
:: The native modules should work as-is since they're from npm
set ELECTRON_SKIP_BINARY_DOWNLOAD=1
set ELECTRON_REBUILD_DISABLED=1

echo === Installing dependencies ===
:: Install all workspace dependencies
:: --frozen-lockfile: Use exact versions from pnpm-lock.yaml
:: --strict-peer-dependencies=false: conda's nodejs may not match exact semver ranges
call pnpm install --frozen-lockfile --strict-peer-dependencies=false
if errorlevel 1 exit /b 1

echo === Building and packaging with electron-builder ===
:: Build TypeScript/Svelte code first
call pnpm build
if errorlevel 1 exit /b 1

:: Package with electron-builder, explicitly disabling publishing and native rebuild
:: --config.npmRebuild=false: Skip native module rebuild (fails with Electron 39.2.6)
call pnpm exec electron-builder --win --x64 --publish never --config.npmRebuild=false
if errorlevel 1 exit /b 1

echo === Generating third-party license notices ===
:: Create combined license file for all npm dependencies
call pnpm licenses generate-disclaimer --prod > ThirdPartyNotices.txt
if errorlevel 1 (
    echo WARNING: License generation had issues, creating placeholder
    echo Third-party licenses information > ThirdPartyNotices.txt
)

:: Verify license files exist
if not exist "LICENSE" (
    echo ERROR: LICENSE file not found
    exit /b 1
)

echo === Installing Podman Desktop to LIBRARY_PREFIX ===
:: First, list what electron-builder created to debug the directory structure
echo Checking dist directory contents:
dir /B dist

:: Install Electron app bundle
if not exist "%LIBRARY_PREFIX%\lib" mkdir "%LIBRARY_PREFIX%\lib"
if not exist "%LIBRARY_PREFIX%\lib\podman-desktop" mkdir "%LIBRARY_PREFIX%\lib\podman-desktop"

:: Copy all files from win-unpacked to installation directory
echo Copying from dist\win-unpacked to %LIBRARY_PREFIX%\lib\podman-desktop
xcopy /E /I /Y "dist\win-unpacked\*" "%LIBRARY_PREFIX%\lib\podman-desktop\"
if errorlevel 1 (
    echo ERROR: Failed to copy dist\win-unpacked
    echo Available directories in dist:
    dir dist
    exit /b 1
)

echo === Creating launcher script ===
:: Create wrapper batch file in Scripts/
if not exist "%SCRIPTS%" mkdir "%SCRIPTS%"

:: Create launcher batch file (use quotes around exe path due to spaces)
(
echo @echo off
echo :: Podman Desktop launcher script
echo :: Execute the Electron app from lib directory
echo start "" "%%LIBRARY_PREFIX%%\lib\podman-desktop\Podman Desktop.exe" %%*
) > "%SCRIPTS%\podman-desktop.bat"

echo === Build completed successfully! ===
echo Installed files:
dir "%SCRIPTS%\podman-desktop.bat"
echo Contents of lib\podman-desktop:
dir "%LIBRARY_PREFIX%\lib\podman-desktop" | findstr /C:"exe"

exit /b 0
