cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo auditable cinstall --locked --prefix %LIBRARY_PREFIX% --libdir %LIBRARY_LIB% --library-type cdylib
if errorlevel 1 exit 1
