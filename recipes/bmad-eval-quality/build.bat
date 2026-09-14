@echo off
setlocal enabledelayedexpansion

:: The GitHub tag archive extracts into bmad-eval-quality-<version>/;
:: rattler-build sets SRC_DIR to that directory, so package.json is in SRC_DIR.
if not exist "package.json" (
    echo ERROR: package.json not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

:: dist/ is not committed upstream: compile TypeScript (needs devDependencies).
call npm ci --no-fund --no-audit --ignore-scripts
if errorlevel 1 exit /b 1
call npm run build
if errorlevel 1 exit /b 1

:: Ship production dependencies only (one prod dep: zod).
if exist node_modules rmdir /S /Q node_modules
call npm ci --omit=dev --no-fund --no-audit --ignore-scripts
if errorlevel 1 exit /b 1

set "INSTALL_DIR=%PREFIX%\lib\node_modules\eval-quality"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Mirror package.json "files" plus package.json and production node_modules.
for %%D in (dist schemas corpus node_modules) do (
    robocopy "%%D" "%INSTALL_DIR%\%%D" /E /XD .bin /NFL /NDL /NJH /NJS /NP
    if !errorlevel! geq 8 exit /b 1
)
copy /Y README.md "%INSTALL_DIR%\README.md" >NUL
copy /Y LICENSE "%INSTALL_DIR%\LICENSE" >NUL
copy /Y package.json "%INSTALL_DIR%\package.json" >NUL

:: Wrapper .bat (no symlinks in a noarch artifact).
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
(
  echo @echo off
  echo SET "DIR=%%~dp0.."
  echo node "%%DIR%%\lib\node_modules\eval-quality\dist\cli\main.js" %%*
) > "%PREFIX%\Scripts\eval-quality.bat"

:: robocopy signals success with exit codes 0-7 (1 = files copied), so the
:: script must not fall off the end and inherit a stale non-zero errorlevel.
exit /b 0
