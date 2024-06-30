cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if %errorlevel% NEQ 0 exit /b %errorlevel%
