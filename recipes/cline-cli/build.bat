@echo on
setlocal enabledelayedexpansion

npm pack --ignore-scripts
if errorlevel 1 exit /b 1

npm install -ddd ^
    --no-bin-links ^
    --global ^
    --build-from-source ^
    cline-%PKG_VERSION%.tgz
if errorlevel 1 exit /b 1

move package.json package.json.bak
if errorlevel 1 exit /b 1

jq "del(.devDependencies)" package.json.bak > package.json
if errorlevel 1 exit /b 1

pnpm install
if errorlevel 1 exit /b 1

pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if errorlevel 1 exit /b 1

(
echo @echo off
echo set "PREFIX_DIR=%%~dp0.."
echo call "%%PREFIX_DIR%%\bin\node.exe" "%%PREFIX_DIR%%\lib\node_modules\cline\bin\cline" %%*
) > "%PREFIX%\bin\cline.cmd"
if errorlevel 1 exit /b 1
