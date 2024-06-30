cargo build --locked --profile release --package zenoh-plugin-rest
if %errorlevel% NEQ 0 exit /b %errorlevel%

if not exist %LIBRARY_PREFIX%\bin mkdir %LIBRARY_PREFIX%\bin
copy .\target\%CARGO_BUILD_TARGET%\release\zenoh_plugin_rest.dll %LIBRARY_PREFIX%\bin\
if %errorlevel% NEQ 0 exit /b %errorlevel%
