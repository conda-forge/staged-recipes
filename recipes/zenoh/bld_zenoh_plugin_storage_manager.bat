cargo build --locked --profile release --package zenoh-plugin-storage-manager
if %errorlevel% NEQ 0 exit /b %errorlevel%

if not exist %LIBRARY_PREFIX%\bin mkdir %LIBRARY_PREFIX%\bin
copy .\target\%CARGO_BUILD_TARGET%\release\zenoh_plugin_storage_manager.dll %LIBRARY_PREFIX%\bin\
if %errorlevel% NEQ 0 exit /b %errorlevel%
