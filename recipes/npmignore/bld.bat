@echo on

call npm install || goto :error
if errorlevel 1 exit 1

call yarn licenses generate-disclaimer > ThirdPartyLicenses.txt
if errorlevel 1 exit 1

call npm config set prefix %BUILD_PREFIX%
if errorlevel 1 exit 1

call npm install --userconfig nonexistentrc --global %PKG_NAME%@%PKG_VERSION%
if errorlevel 1 exit 1
