@echo on

call npm pack --ignore-scripts || goto :error
call npm install -ddd --global --no-bin-links --build-from-source %SRC_DIR%\zed-industries-claude-agent-acp-%PKG_VERSION%.tgz || goto :error

:: Create license report for dependencies
call pnpm install || goto :error
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || goto :error

:: Create bin wrappers (noarch: both Unix and Windows wrappers needed)
mkdir %PREFIX%\bin 2>nul
(
echo #!/bin/sh
echo exec node "$CONDA_PREFIX/lib/node_modules/@zed-industries/claude-agent-acp/dist/index.js" "$@"
) > %PREFIX%\bin\claude-agent-acp || goto :error
(echo @call "%%CONDA_PREFIX%%\bin\node" "%%PREFIX%%\lib\node_modules\@zed-industries\claude-agent-acp\dist\index.js" %%*) > %PREFIX%\bin\claude-agent-acp.cmd || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
