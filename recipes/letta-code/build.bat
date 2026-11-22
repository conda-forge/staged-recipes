@echo on
set "npm_config_cache=%SRC_DIR%\.npm-cache"
set "NODE_GYP_FORCE_PYTHON=%BUILD_PREFIX%\python.exe"
set "NODE_USE_SYSTEM_CA=1"
set "SCARF_ANALYTICS=false"
set "DO_NOT_TRACK=1"
set "SHARP_FORCE_GLOBAL_LIBVIPS=1"

rem The optional Cursor SDK contains proprietary prebuilt binaries.
call npm pkg delete dependencies.@cursor/sdk
if errorlevel 1 exit /b 1
call npm install --global --prefix "%PREFIX%" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
if errorlevel 1 exit /b 1
cd /d "%PREFIX%\node_modules\@letta-ai\letta-code"
node scripts\postinstall-patches.js
if errorlevel 1 exit /b 1

rem Replace npm's prebuilt native dependencies with conda libraries.
node -e "const fs = require('fs'); for (const p of fs.globSync('**/node_modules/{@vscode/ripgrep*,@img/sharp-*,@janhapke}')) fs.rmSync(p, {recursive:true, force:true});"
if errorlevel 1 exit /b 1
cd node_modules
patch --binary -p1 < "%RECIPE_DIR%\native-deps.patch"
if errorlevel 1 exit /b 1
cd node-pty
rmdir /s /q prebuilds
rmdir /s /q third_party
node "%BUILD_PREFIX%\node_modules\node-gyp\bin\node-gyp.js" rebuild --devdir "%SRC_DIR%\node-headers" --msvs_version=2022
if errorlevel 1 exit /b 1
rmdir /s /q deps
cd ..\sharp\src
node "%BUILD_PREFIX%\node_modules\node-gyp\bin\node-gyp.js" rebuild --devdir "%SRC_DIR%\node-headers" --msvs_version=2022
if errorlevel 1 exit /b 1
cd ..\..
node -e "const fs = require('fs'); const binary = fs.globSync('sharp/src/build/Release/sharp-*.node')[0].replaceAll('\\', '/'); const name = require('./sharp/package.json').version; const dir = '@img/' + require('path').basename(binary).replace('-' + name + '.node', ''); fs.mkdirSync(dir, {recursive:true}); fs.writeFileSync(dir + '/sharp.node.js', 'module.exports = require(\"../../' + binary + '\");');"
if errorlevel 1 exit /b 1
cd ..

rem Let npm enumerate the installed tree and pnpm-licenses collect its licenses.
call npm query "*" > "%SRC_DIR%\npm-dependencies.json"
if errorlevel 1 exit /b 1
node -e "const fs = require('fs'); const dependencies = require(process.env.SRC_DIR + '/npm-dependencies.json').filter(p => p.name && p.version).map(p => ({...p, license:p.license || 'UNKNOWN', author:typeof p.author === 'object' ? p.author.name : p.author})); fs.writeFileSync(process.env.SRC_DIR + '/licenses.json', JSON.stringify({dependencies}));"
if errorlevel 1 exit /b 1
call pnpm-licenses generate-disclaimer --json-input-file "%SRC_DIR%\licenses.json" --output-file "%SRC_DIR%\THIRDPARTY.txt"
if errorlevel 1 exit /b 1
rem Preserve original license files and additional notices alongside the disclaimer.
node -e "const fs = require('fs'), path = require('path'); for (const p of fs.globSync('**/{LICENSE*,LICENCE*,license*,licence*,COPYING*,NOTICE*,*NOTICES*,*notices*,COPYRIGHT*,Copyright*,copyright*,ThirdParty*,third-party*}')) { const dest = path.join(process.env.SRC_DIR, 'third-party-licenses', p); fs.mkdirSync(path.dirname(dest), {recursive:true}); fs.cpSync(p, dest, {recursive:true}); }"
if errorlevel 1 exit /b 1
