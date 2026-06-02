@echo off
setlocal enabledelayedexpansion

if not exist "package.json" (
    echo ERROR: package.json not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

:: Install production npm dependencies (no devDependencies, no scripts).
:: --no-bin-links matches the Unix build; the package is consumed as a library,
:: not a CLI, so npm's node_modules/.bin/ shims are unnecessary and would
:: introduce platform-specific files into a noarch package.
call npm install --omit=dev --no-fund --no-audit --ignore-scripts --no-bin-links
if errorlevel 1 exit /b 1

:: Capture the licenses of every bundled production dependency in node_modules.
:: conda-forge requires the licenses of all shipped code to be recorded; the file
:: is written to SRC_DIR (cwd) and referenced from about.license_file.
call node "%RECIPE_DIR%\gen-third-party-licenses.js"
if errorlevel 1 exit /b 1

:: Create the installation directory
set "INSTALL_DIR=%PREFIX%\lib\node_modules\%PKG_NAME%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy package files (source + node_modules), excluding dev-only directories.
:: Use robocopy to avoid Windows MAX_PATH issues in website/ and docs/ trees.
robocopy . "%INSTALL_DIR%" /E ^
  /XD website docs test .husky .github .vscode .augment .claude-plugin coverage test-output ^
  /NFL /NDL /NJH /NJS /NP
:: robocopy exit codes 0-7 are success; 8+ indicate errors.
if %errorlevel% geq 8 exit /b 1
