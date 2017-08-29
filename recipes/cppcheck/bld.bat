msiexec /a %PKG_NAME%-%PKG_VERSION%-%TARGET_ARCH%-Setup.msi /qb TARGETDIR=%TEMP% || exit 1

if not exist %SCRIPTS% mkdir %SCRIPTS% || exit 1

dir %TEMP% /s /b /o:gn

copy %TEMP%\cppchk\*.exe %SCRIPTS% || exit 1
