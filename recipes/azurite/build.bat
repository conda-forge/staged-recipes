@echo on

:: Ensure build environment binaries are in PATH
set "PATH=%BUILD_PREFIX%\bin;%BUILD_PREFIX%;%PATH%"
set "NPM_CONFIG_USERCONFIG=%TEMP%\nonexistentrc"

:: Install azurite globally into %PREFIX%
cmd /c npm install -g %PKG_NAME%@%PKG_VERSION% --omit=dev --ignore-scripts || exit /b 1

:: Remove packageManager field using jq
cmd /c jq "del(.packageManager)" package.json > package.json.tmp || exit /b 1
move /y package.json.tmp package.json || exit /b 1

:: Generate package lock, import to pnpm, and generate licenses
cmd /c npm install --package-lock-only --omit=dev --ignore-scripts || exit /b 1

cmd /c pnpm import || exit /b 1

cmd /c pnpm install --prod --ignore-scripts || exit /b 1

cmd /c pnpm licenses list --json --prod > licenses.json || exit /b 1

cmd /c pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt < licenses.json || exit /b 1