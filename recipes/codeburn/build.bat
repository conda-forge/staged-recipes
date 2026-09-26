@echo on

call npm pack --ignore-scripts || goto :error

:: --prefix %PREFIX%\lib keeps the Windows install at lib\node_modules, matching
:: the Unix layout the shipped noarch package is built from
call npm install -ddd --global --no-bin-links --prefix "%PREFIX%\lib" "%SRC_DIR%\%PKG_NAME%-%PKG_VERSION%.tgz" || goto :error

:: License report for the bundled runtime dependency tree
call pnpm install --prod --ignore-scripts || goto :error
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || goto :error

mkdir "%PREFIX%\bin" 2>nul
(
echo #!/bin/sh
echo exec "$CONDA_PREFIX/bin/node" "$CONDA_PREFIX/lib/node_modules/codeburn/dist/cli.js" "$@"
) > "%PREFIX%\bin\codeburn" || goto :error
(echo @call "%%CONDA_PREFIX%%\node.exe" "%%CONDA_PREFIX%%\lib\node_modules\codeburn\dist\cli.js" %%*) > "%PREFIX%\bin\codeburn.cmd" || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
