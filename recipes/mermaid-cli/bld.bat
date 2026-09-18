@echo on

:: prevent puppeteer from downloading chromium
set PUPPETEER_SKIP_DOWNLOAD=1

call npm install -g --prefix=%PREFIX% @mermaid-js/mermaid-cli@%PKG_VERSION%
if errorlevel 1 exit 1

for /r "%PREFIX%" %%f in (*.bare) do del /q "%%f"
for /d /r "%PREFIX%" %%d in (prebuilds) do rmdir /s /q "%%d"

:: remove native napi canvas binary
if exist "%PREFIX%\node_modules\@mermaid-js\mermaid-cli\node_modules\@napi-rs" rmdir /s /q "%PREFIX%\node_modules\@mermaid-js\mermaid-cli\node_modules\@napi-rs"

:: generate a third-party license disclaimer for the bundled node_modules
call pnpm install --prod --ignore-scripts
if errorlevel 1 exit 1
cmd /c "pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file=%SRC_DIR%\third-party-licenses.txt"
if errorlevel 1 exit 1
