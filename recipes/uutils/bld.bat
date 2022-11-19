REM Don't override the binaries being used by the build
set TMP_PREFIX=%LIBRARY_PREFIX%\tmp_prefix
for /f "usebackq tokens=*" %%i in (`cygpath %TMP_PREFIX%`) do set CONVERTED_PREFIX=%%i

cargo build --release --features windows
cargo install --path . --root "%TMP_PREFIX%" --features windows
make PROFILE=Release PREFIX="%CONVERTED_PREFIX%" MULTICALL=y PROG_SUFFIX=.exe install
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

mv /y "%TMP_PREFIX%" "%LIBRARY_PREFIX%"
