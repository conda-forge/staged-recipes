msiexec /a %PKG_NAME%-%PKG_VERSION%-%TARGET_ARCH%-Setup.msi /qb TARGETDIR=%TEMP% || exit 1

if not exist %SCRIPTS% mkdir %SCRIPTS% || exit 1

xcopy /s %TEMP%\PFiles\Cppcheck\* %SCRIPTS% || exit 1
