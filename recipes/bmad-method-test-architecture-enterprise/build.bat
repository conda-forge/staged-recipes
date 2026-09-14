@echo off
setlocal enabledelayedexpansion

if not exist "src" (
    echo ERROR: src\ directory not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

set SHARE=%PREFIX%\share\bmad-method-test-architecture-enterprise
if not exist "%SHARE%" mkdir "%SHARE%"
xcopy /E /I /Q src\agents "%SHARE%\agents\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q src\workflows "%SHARE%\workflows\"
if errorlevel 1 exit /b 1
copy src\module-help.csv "%SHARE%\"
if errorlevel 1 exit /b 1
copy src\module.yaml "%SHARE%\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q .claude-plugin "%SHARE%\.claude-plugin\"
if errorlevel 1 exit /b 1
copy CHANGELOG.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy LICENSE "%SHARE%\"
if errorlevel 1 exit /b 1
copy README.md "%SHARE%\"
if errorlevel 1 exit /b 1

rem Node CLIs (upstream package.json "bin"). 1.20.0 first shipped a working
rem tea-test-review; 1.25.0 added tea-fragment-selection-runner + tea-trace-runner.
rem Vendor cli/ + production node_modules next to it so require() resolves.
call npm install --omit=dev --ignore-scripts --no-audit --no-fund
if errorlevel 1 exit /b 1
xcopy /E /I /Q cli "%SHARE%\cli\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q node_modules "%SHARE%\node_modules\"
if errorlevel 1 exit /b 1
rem cli\lib\review-provenance.js (new in 1.25.0) does require("../../package.json")
rem to stamp teaCliVersion, so the manifest must sit at the share\ root beside cli\.
copy package.json "%SHARE%\"
if errorlevel 1 exit /b 1
for /f "delims=" %%d in ('dir /b /s /ad "%SHARE%\node_modules\.bin" 2^>nul') do rmdir /s /q "%%d"
if exist "%SHARE%\node_modules\.bin" rmdir /s /q "%SHARE%\node_modules\.bin"

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\bmad_tea_install.py" "%PREFIX%\Scripts\bmad-tea-install-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\bmad-tea-install-script.py" %%*
) > "%PREFIX%\Scripts\bmad-tea-install.bat"
rem One .bat shim per upstream bin entry. Keep in lockstep with package.json
rem "bin" on every version bump (CFE G110).
(
  echo @node "%PREFIX%\share\bmad-method-test-architecture-enterprise\cli\test-review.js" %%*
) > "%PREFIX%\Scripts\tea-test-review.bat"
(
  echo @node "%PREFIX%\share\bmad-method-test-architecture-enterprise\cli\fragment-selection-runner.js" %%*
) > "%PREFIX%\Scripts\tea-fragment-selection-runner.bat"
(
  echo @node "%PREFIX%\share\bmad-method-test-architecture-enterprise\cli\trace-runner.js" %%*
) > "%PREFIX%\Scripts\tea-trace-runner.bat"

rem xcopy/robocopy-style tools can leave a non-zero errorlevel; exit explicitly.
exit /b 0
