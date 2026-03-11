@echo on

npm pack --ignore-scripts || goto :error
npm install -ddd --global --no-bin-links --build-from-source %SRC_DIR%\zed-industries-claude-agent-acp-%PKG_VERSION%.tgz || goto :error

:: Create license report for dependencies
pnpm install || goto :error
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || goto :error

:: Create bin wrapper
mkdir %PREFIX%\bin 2>nul
(echo @call "%%CONDA_PREFIX%%\bin\node" "%%PREFIX%%\lib\node_modules\@zed-industries\claude-agent-acp\dist\index.js" %%*) > %PREFIX%\bin\claude-agent-acp.cmd || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
