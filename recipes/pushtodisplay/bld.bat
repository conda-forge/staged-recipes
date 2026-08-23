set "npm_config_cache=%SRC_DIR%\.npm-cache"
npm pack --ignore-scripts
npm install -g --prefix "%PREFIX%" "pushtodisplay-%PKG_VERSION%.tgz"
if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"
echo @echo off> "%PREFIX%\Library\bin\pushtodisplay.cmd"
echo node "%%~dp0..\..\node_modules\pushtodisplay\dist\cli.js" %%*>> "%PREFIX%\Library\bin\pushtodisplay.cmd"
echo $ErrorActionPreference = 'Stop'> "%PREFIX%\Library\bin\pushtodisplay.ps1"
echo node $PSScriptRoot\..\..\node_modules\pushtodisplay\dist\cli.js $args>> "%PREFIX%\Library\bin\pushtodisplay.ps1"
