@echo on
setlocal EnableExtensions

@REM Create license report for dependencies
call pnpm install --prod --ignore-scripts || exit /b 1
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || exit /b 1

@REM Install globally
call pnpm pack --config.ignore-scripts=true || exit /b 1
call npm install -ddd --global --prefix "%PREFIX%" --ignore-scripts %PKG_NAME%-%PKG_VERSION%.tgz || exit /b 1
