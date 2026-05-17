@echo off

:: Tell npm to install into %PREFIX% rather than its default user prefix,
:: and ignore the user .npmrc so CI behavior is reproducible.
call npm config set prefix "%PREFIX%"
if errorlevel 1 exit /b 1

:: Pack the package source as a tarball and install it globally into the
:: conda prefix. `npm install --global` creates the .cmd bin shims for us
:: on Windows (no symlinks to strip, unlike the Unix build).
call npm pack --ignore-scripts
if errorlevel 1 exit /b 1

call npm install -ddd --global --build-from-source --userconfig nonexistentrc ^
    "%SRC_DIR%\yo-%PKG_VERSION%.tgz"
if errorlevel 1 exit /b 1

:: Generate the third-party license disclaimer (required by conda-forge for
:: npm packages with runtime dependencies -- declared in about.license_file).
call pnpm install
if errorlevel 1 exit /b 1

call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if errorlevel 1 exit /b 1
