@echo on

@rem Handle platform-specific logic for arm64
if "%target_platform%" == "osx-arm64" (
    set npm_config_arch=arm64
)

@rem Don't use pre-built gyp packages
set npm_config_build_from_source=true

@rem Remove the existing node binary and create a new symlink
del %PREFIX%\bin\node
mklink %PREFIX%\bin\node %BUILD_PREFIX%\bin\node

@rem Install speedscope from the npm registry
set NPM_CONFIG_USERCONFIG=%TEMP%\nonexistentrc
cmd /c "npm install -g speedscope@%PKG_VERSION%"
if errorlevel 1 exit 1

@rem Port yarn.lock to pnpm-lock.yaml
cmd /c "pnpm import"
if errorlevel 1 exit 1

@rem Install all (prod) dependencies
cmd /c "pnpm install --prod"
if errorlevel 1 exit 1

@rem List all dependencies and then call pnpm-licenses to generate the third-party-licenses.txt file
cmd /c "pnpm licenses list --prod --json | pnpm-licenses generate-disclaimer --prod --json-input --output-file=third-party-licenses.txt"
if errorlevel 1 exit 1

@rem Log directory structure for verification
dir
