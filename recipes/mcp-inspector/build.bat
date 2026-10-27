@echo on

:: Create package archive and install globally
call npm pack --ignore-scripts
if errorlevel 1 exit 1
call npm install -ddd --global modelcontextprotocol-inspector-%PKG_VERSION%.tgz
if errorlevel 1 exit 1

:: Create license report for dependencies
call pnpm install --ignore-scripts
if errorlevel 1 exit 1
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if errorlevel 1 exit 1
