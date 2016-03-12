msiexec /a pandoc-%PKG_VERSION%-windows.msi /qb TARGETDIR=%TEMP%
mkdir %SCRIPTS%
copy %TEMP%\Pandoc\*.exe %SCRIPTS%
