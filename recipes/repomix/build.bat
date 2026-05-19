@echo off
setlocal enabledelayedexpansion

pnpm pack --config.ignore-scripts=true
if %ERRORLEVEL% neq 0 exit /b 1

npm install -ddd ^
    --global ^
    --prefix "%PREFIX%" ^
    --ignore-scripts ^
    --no-bin-links ^
    %PKG_NAME%-%PKG_VERSION%.tgz
if %ERRORLEVEL% neq 0 exit /b 1

copy /Y package.json package.json.bak >nul
if %ERRORLEVEL% neq 0 exit /b 1

jq "del(.devDependencies)" package.json.bak > package.json
if %ERRORLEVEL% neq 0 exit /b 1

pnpm install --ignore-scripts
if %ERRORLEVEL% neq 0 exit /b 1
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if %ERRORLEVEL% neq 0 exit /b 1

echo call %%CONDA_PREFIX%%\bin\node %%CONDA_PREFIX%%\lib\node_modules\repomix\bin\repomix.cjs %%* > "%PREFIX%\bin\repomix.cmd"
if %ERRORLEVEL% neq 0 exit /b 1

