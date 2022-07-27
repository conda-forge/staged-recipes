cargo bundle-licenses --format yaml --output DENO_DOM_THIRDPARTY_LICENSES.yml
cargo build --release

IF %errorlevel% NEQ 0 exit 1

MKDIR %LIBRARY_PREFIX%\lib
COPY target\release\libplugin.dll %LIBRARY_PREFIX%\lib\deno_dom.dll

MKDIR "%PREFIX%\etc\conda\activate.d"
MKDIR "%PREFIX%\etc\conda\deactivate.d"
echo set "DENO_DOM_PLUGIN=%LIBRARY_PREFIX:/=\%\lib\deno_dom.dll" > %PREFIX%\etc\conda\activate.d\deno_dom.bat
echo set DENO_DOM_PLUGIN= > %PREFIX%\etc\conda\deactivate.d\deno_dom.bat
