@echo on
setlocal enabledelayedexpansion

:: Fail on error
set ERRORS=0

:: Fix package.json so it can bootstrap itself
:: Remove preinstall script because it needs devDependencies that need to be installed
:: with npm install
:: Remove compile command from post install script so we don't try to transpile
:: typescript again
rename package.json package.json.bak
jq "del(.scripts.preinstall)" package.json.bak > package.json
sed -i 's/setup compile sh:relink/setup sh:relink/' package.json

:: Install dependencies without running postinstall
npm install --ignore-scripts

:: Uninstall 'tsc' and install 'typescript'
npm uninstall tsc
npm install typescript

:: Run compile script
npm run compile

:: Add 'fast-glob' as a production dependency
npm install fast-glob --save-prod

:: Pack the package without running lifecycle scripts
npm pack --ignore-scripts

:: Create a bin directory and link run-s from npm-run-all
mkdir bin
mklink bin\run-s node_modules\npm-run-all\bin\run-s\index.js

:: Add our local bin directory to the PATH
set "PATH=%SRC_DIR%\bin;%PATH%"

:: Install the packed tgz globally
npm install -ddd --global --build-from-source %SRC_DIR%\%PKG_NAME%-%PKG_VERSION:_=-%).tgz

:: Generate license report
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

endlocal

if errorlevel 1 (
    echo Installation failed!
    exit /b 1
)

exit /b 0
