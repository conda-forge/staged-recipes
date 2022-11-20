cargo build --release --features windows
if errorlevel 1 exit 1

make PROFILE=Release PREFIX="%LIBRARY_PREFIX%" MULTICALL=y PROG_SUFFIX=.exe install
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

dir %LIBRARY_BIN%
if errorlevel 1 exit 1
