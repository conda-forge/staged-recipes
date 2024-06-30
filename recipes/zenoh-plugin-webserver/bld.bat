cargo build --locked --profile release
if %errorlevel% NEQ 0 exit /b %errorlevel%

if not exist %LIBRARY_PREFIX%\bin mkdir %LIBRARY_PREFIX%\bin
copy .\target\%CARGO_BUILD_TARGET%\release\zenoh_plugin_webserver.dll %LIBRARY_PREFIX%\bin\
if %errorlevel% NEQ 0 exit /b %errorlevel%

cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if %errorlevel% NEQ 0 exit /b %errorlevel%
