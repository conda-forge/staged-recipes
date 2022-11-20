cargo build --release --features windows
if errorlevel 1 exit 1

where coreutils
make PROFILE=Release PREFIX="%CYGWIN_PREFIX%/Library" MULTICALL=y PROG_SUFFIX=.exe install
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

dir %LIBRARY_BIN%
if errorlevel 1 exit 1
