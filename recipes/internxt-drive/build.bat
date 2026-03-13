@echo on
setlocal enabledelayedexpansion

:: ============================================================
:: Phase 1: Create .env for dotenv-webpack build-time injection
:: ============================================================
:: The webpack build uses dotenv-webpack to inject these values.
:: API URLs are Internxt's public production endpoints.
(
echo NODE_ENV=production
echo BRIDGE_URL=https://api.internxt.com
echo DRIVE_URL=https://drive.internxt.com
echo PAYMENTS_URL=https://payments.internxt.com
echo NOTIFICATIONS_URL=https://notifications.internxt.com
echo DESKTOP_HEADER=internxt-drive-desktop
echo NEW_CRYPTO_KEY=PLACEHOLDER_USER_MUST_CONFIGURE
echo ANALYZE=false
echo PORT=3000
) > .env
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 2: Build native C++ addon (packages/addon)
:: ============================================================
:: Must happen before npm ci because package.json references
:: file:packages/addon/packages-addon-1.0.0.tgz which does not
:: exist in the source archive.
pushd packages\addon
call npm install --ignore-scripts
if errorlevel 1 (popd & exit /b 1)
call npx node-gyp configure
if errorlevel 1 (popd & exit /b 1)
call npx node-gyp build
if errorlevel 1 (popd & exit /b 1)
:: Create the tarball that the root package.json expects
call npm pack
if errorlevel 1 (popd & exit /b 1)
popd

:: ============================================================
:: Phase 3: Install JavaScript dependencies
:: ============================================================
:: --ignore-scripts prevents postinstall from running
:: electron-rebuild prematurely; we handle native modules below.
call npm ci --ignore-scripts
if errorlevel 1 exit /b 1

:: Download the Electron binary (skipped by --ignore-scripts)
call node node_modules\electron\install.js
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 4: Rebuild native modules for Electron's Node ABI
:: ============================================================
set npm_config_build_from_source=true
call npx electron-rebuild -f -w better-sqlite3
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 5: Webpack production build (main + renderer + preload)
:: ============================================================
call npm run build
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 6: Prune devDependencies to reduce package size
:: ============================================================
call npm prune --production
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 7: Install into conda prefix
:: ============================================================
set INSTALL_DIR=%LIBRARY_PREFIX%\lib\internxt-drive

mkdir "%INSTALL_DIR%" 2>nul
mkdir "%INSTALL_DIR%\dist" 2>nul
mkdir "%INSTALL_DIR%\node_modules" 2>nul

:: Copy webpack build output
xcopy /E /I /Y dist "%INSTALL_DIR%\dist"
if errorlevel 1 exit /b 1

:: Copy production node_modules (native modules + runtime deps)
xcopy /E /I /Y node_modules "%INSTALL_DIR%\node_modules"
if errorlevel 1 exit /b 1

:: Copy package.json (electron needs it to resolve the app)
copy /Y package.json "%INSTALL_DIR%\package.json"
if errorlevel 1 exit /b 1

:: Copy assets if present
if exist assets (
    xcopy /E /I /Y assets "%INSTALL_DIR%\assets"
)

:: ============================================================
:: Phase 8: Create launcher script
:: ============================================================
set BIN_DIR=%LIBRARY_PREFIX%\bin
mkdir "%BIN_DIR%" 2>nul

(
echo @echo off
echo setlocal
echo set "APP_DIR=%%CONDA_PREFIX%%\Library\lib\internxt-drive"
echo "%%APP_DIR%%\node_modules\.bin\electron.cmd" "%%APP_DIR%%\dist\main\main.js" %%*
echo endlocal
) > "%BIN_DIR%\internxt-drive.cmd"
if errorlevel 1 exit /b 1

:: ============================================================
:: Phase 9: Generate third-party license report
:: ============================================================
call pnpm install --no-frozen-lockfile 2>nul
call pnpm-licenses generate-disclaimer --prod --output-file="%SRC_DIR%\third-party-licenses.txt"
if errorlevel 1 (
    echo WARNING: pnpm-licenses failed, creating placeholder
    echo Third-party licenses could not be generated automatically. > "%SRC_DIR%\third-party-licenses.txt"
)

echo Build completed successfully.
