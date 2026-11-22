@echo on
set "npm_config_cache=%SRC_DIR%\.npm-cache"
set "NODE_GYP_FORCE_PYTHON=%BUILD_PREFIX%\python.exe"
set "NODE_USE_SYSTEM_CA=1"
set "SCARF_ANALYTICS=false"
set "DO_NOT_TRACK=1"

python "%RECIPE_DIR%\build_support.py" prepare
if errorlevel 1 exit /b 1
call npm install --global --prefix "%PREFIX%" --install-links --ignore-scripts --omit=dev --no-audit --no-fund .
if errorlevel 1 exit /b 1
set "LETTA_ROOT=%PREFIX%\node_modules\@letta-ai\letta-code"
python "%RECIPE_DIR%\build_support.py" native "%LETTA_ROOT%"
if errorlevel 1 exit /b 1
node "%LETTA_ROOT%\scripts\postinstall-patches.js"
if errorlevel 1 exit /b 1
python "%RECIPE_DIR%\licenses.py" "%LETTA_ROOT%" "%SRC_DIR%\bundled-licenses" "%SRC_DIR%\THIRDPARTY.txt"
if errorlevel 1 exit /b 1
