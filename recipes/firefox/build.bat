msiexec /a firefox.msi /qb TARGETDIR=%TEMP% || exit 1

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN% || exit 1

copy %TEMP%\Firefox\*.exe %LIBRARY_BIN% || exit 1
