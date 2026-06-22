@echo on
setlocal enabledelayedexpansion

call npm pack --ignore-scripts
if %ERRORLEVEL% neq 0 exit 1

rem Force npm to use lib\node_modules\ on Windows, matching the Linux global layout
set NPM_CONFIG_PREFIX=%PREFIX%\lib
call npm install -ddd ^
    --global ^
    --no-bin-links ^
    --build-from-source ^
    %SRC_DIR%\repomix-%PKG_VERSION%.tgz
if %ERRORLEVEL% neq 0 exit 1

call pnpm install --ignore-scripts
if %ERRORLEVEL% neq 0 exit 1

call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if %ERRORLEVEL% neq 0 exit 1

if not exist %PREFIX%\bin mkdir %PREFIX%\bin

(
    echo #!/bin/sh
    echo exec ${CONDA_PREFIX}/lib/node_modules/repomix/bin/repomix.cjs "$@"
) > %PREFIX%\bin\repomix

echo call node %%CONDA_PREFIX%%\lib\node_modules\repomix\bin\repomix.cjs %%* > %PREFIX%\bin\repomix.cmd
