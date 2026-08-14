@echo on

set "npm_config_cache=%SRC_DIR%\.npm-cache"
call npm pack --ignore-scripts --silent --pack-destination "%BUILD_PREFIX%"
if errorlevel 1 exit 1
call npm install --global --ignore-scripts --silent "%BUILD_PREFIX%\npm-%PKG_VERSION%.tgz" --prefix "%LIBRARY_PREFIX%\share\npm"
if errorlevel 1 exit 1

mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\npm_activate.bat" "%PREFIX%\etc\conda\activate.d\npm.bat"
copy "%RECIPE_DIR%\npm_activate.ps1" "%PREFIX%\etc\conda\activate.d\npm.ps1"
copy "%RECIPE_DIR%\npm_deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\npm.bat"
copy "%RECIPE_DIR%\npm_deactivate.ps1" "%PREFIX%\etc\conda\deactivate.d\npm.ps1"
if errorlevel 1 exit 1
