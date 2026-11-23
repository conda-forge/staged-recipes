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

rem Replace npm's prebuilt dependencies with builds using conda libraries.
for /d %%D in (node_modules\@vscode\ripgrep* node_modules\@img\sharp-* node_modules\@janhapke) do if exist "%%D" rmdir /s /q "%%D"
copy /y "%SRC_DIR%\native-sources\node-pty\binding.gyp" node_modules\node-pty\
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\native-sources\sharp\src\binding.gyp" node_modules\sharp\src\
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\native-sources\sharp\dist\libvips.cjs" node_modules\sharp\dist\
if errorlevel 1 exit /b 1

cd node_modules\node-pty
rmdir /s /q prebuilds
rmdir /s /q third_party
call "%BUILD_PREFIX%\node-gyp.cmd" rebuild --devdir "%SRC_DIR%\node-headers" --msvs_version=2022
if errorlevel 1 exit /b 1
rmdir /s /q deps
cd ..\sharp\src
call "%BUILD_PREFIX%\node-gyp.cmd" rebuild --devdir "%SRC_DIR%\node-headers" --msvs_version=2022
if errorlevel 1 exit /b 1
cd ..\..
rem The bundled Letta code looks for sharp under @img.
for %%F in (sharp\src\build\Release\sharp-*.node) do (
    for /f "tokens=1-3 delims=-" %%A in ("%%~nF") do (
        mkdir "@img\%%A-%%B-%%C"
        copy /y "%%F" "@img\%%A-%%B-%%C\sharp.node"
        if errorlevel 1 exit /b 1
    )
)
cd ..

rem Adapt npm's package metadata to pnpm-licenses' input format.
call npm query "*" > "%SRC_DIR%\npm-dependencies.json"
if errorlevel 1 exit /b 1
jq "{dependencies: map(select(.name and .version) | .author |= (if type == \"object\" then .name else . end) | del(.author | nulls) | .license //= \"UNKNOWN\")}" ^
    "%SRC_DIR%\npm-dependencies.json" > "%SRC_DIR%\licenses.json"
if errorlevel 1 exit /b 1
call pnpm-licenses generate-disclaimer --json-input-file "%SRC_DIR%\licenses.json" --output-file "%SRC_DIR%\THIRDPARTY.txt"
if errorlevel 1 exit /b 1

rem Keep original licenses and notices. Robocopy codes below 8 indicate success.
robocopy . "%SRC_DIR%\third-party-licenses" *LICENSE* *LICENCE* *NOTICE* *COPYING* *COPYRIGHT* *ThirdParty* /S /R:0 /W:0 /NFL /NDL
if errorlevel 8 exit /b 1
exit /b 0
