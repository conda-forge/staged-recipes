@echo on

:: Create package archive and install globally (skip scripts to avoid auth check)
call npm pack --ignore-scripts
if errorlevel 1 exit 1
call npm install -ddd --global --build-from-source --ignore-scripts "%SRC_DIR%\*.tgz"
if errorlevel 1 exit 1

:: Generate third-party license file
call pnpm install --ignore-scripts
if errorlevel 1 exit 1
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if errorlevel 1 exit 1
