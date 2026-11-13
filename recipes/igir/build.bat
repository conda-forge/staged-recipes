@echo on

set "NPM_CONFIG_USERCONFIG=%SRC_DIR%\nonexistent-userrc"
set "NPM_CONFIG_GLOBALCONFIG=%SRC_DIR%\nonexistent-globalrc"
set "npm_config_minimum_release_age=0"

@rem Install the pre-built npm package into Library\share\igir
md %LIBRARY_PREFIX%\share\igir
pushd %LIBRARY_PREFIX%\share\igir
md node_modules
cmd /c "npm install %SRC_DIR%\igir-%PKG_VERSION%.tgz"
if errorlevel 1 exit 1

@rem Only keep the prebuilt native addons for the target platform
for /d %%d in (node_modules\igir\dist\addons\*) do (
  for /d %%p in (%%d\addon-*\prebuilds\*) do (
    if /i not "%%~nxp"=="win32-x64" rd /s /q "%%p"
  )
)
popd

@rem Launcher for the igir command
pushd %LIBRARY_PREFIX%\bin
echo @echo off > igir.bat
echo "%%~dp0..\share\igir\node_modules\.bin\igir.cmd" %%* >> igir.bat
popd

@rem Generate ThirdPartyLicenses.txt for the bundled npm dependencies
cmd /c "pnpm import"
if errorlevel 1 exit 1
cmd /c "pnpm install --prod --ignore-scripts"
if errorlevel 1 exit 1
cmd /c "pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file=ThirdPartyLicenses.txt"
if errorlevel 1 exit 1
