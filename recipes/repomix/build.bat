@echo on
setlocal

set "PATH=%BUILD_PREFIX%\bin;%BUILD_PREFIX%\Scripts;%BUILD_PREFIX%;%PATH%"
set "NPM_CONFIG_USERCONFIG=%TEMP%\nonexistentrc"

@rem Pack the published files and install them into the target prefix.
cmd /c pnpm pack --config.ignore-scripts=true
if errorlevel 1 exit /b 1

cmd /c npm install -ddd --global --prefix "%PREFIX%" --ignore-scripts --no-bin-links "%PKG_NAME%-%PKG_VERSION%.tgz"
if errorlevel 1 exit /b 1

@rem Upstream does not publish a lockfile. Generate an npm lockfile first so
@rem pnpm can import the resolved production dependency graph for licenses.
cmd /c npm pkg delete devDependencies
if errorlevel 1 exit /b 1

cmd /c npm install --package-lock-only --omit=dev --ignore-scripts
if errorlevel 1 exit /b 1

cmd /c pnpm import
if errorlevel 1 exit /b 1

cmd /c pnpm install --prod --frozen-lockfile --ignore-scripts
if errorlevel 1 exit /b 1

cmd /c pnpm licenses list --prod --json > licenses.json
if errorlevel 1 exit /b 1

cmd /c pnpm-licenses generate-disclaimer --json-input --output-file=third-party-licenses.txt < licenses.json
if errorlevel 1 exit /b 1

@rem Create the Windows wrapper with runtime-relative paths.
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
if errorlevel 1 exit /b 1

> "%PREFIX%\Scripts\repomix.cmd" echo @echo off
>> "%PREFIX%\Scripts\repomix.cmd" echo "%%CONDA_PREFIX%%\node.exe" "%%CONDA_PREFIX%%\node_modules\repomix\bin\repomix.cjs" %%*
if errorlevel 1 exit /b 1

exit /b 0
