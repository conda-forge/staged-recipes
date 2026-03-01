@echo off
setlocal enabledelayedexpansion

if not exist "package.json" (
    echo ERROR: package.json not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

:: Install production npm dependencies (no devDependencies, no scripts)
call npm install --omit=dev --no-fund --no-audit --ignore-scripts
if errorlevel 1 exit /b 1

:: Create the installation directory
set "INSTALL_DIR=%PREFIX%\lib\node_modules\%PKG_NAME%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy package files (source + node_modules)
xcopy /E /I /Y . "%INSTALL_DIR%\"
if errorlevel 1 exit /b 1

:: Create Scripts directory for wrapper .bat files
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

:: Create bmad.bat wrapper
(
  echo @echo off
  echo SET "DIR=%%~dp0.."
  echo node "%%DIR%%\lib\node_modules\bmad-method\tools\bmad-npx-wrapper.js" %%*
) > "%PREFIX%\Scripts\bmad.bat"

:: Create bmad-method.bat wrapper
(
  echo @echo off
  echo SET "DIR=%%~dp0.."
  echo node "%%DIR%%\lib\node_modules\bmad-method\tools\bmad-npx-wrapper.js" %%*
) > "%PREFIX%\Scripts\bmad-method.bat"
