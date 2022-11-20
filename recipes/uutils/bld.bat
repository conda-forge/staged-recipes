REM Build tools clobber the target directory
set TMP_PREFIX=%SRC_DIR%\tmp_prefix
for /f "usebackq tokens=*" %%i in (`cygpath %TMP_PREFIX%`) do set CONVERTED_PREFIX=%%i

cargo build --release --features windows
cargo install --path . --root "%TMP_PREFIX%" --features windows
make PROFILE=Release PREFIX="%CONVERTED_PREFIX%" MULTICALL=y PROG_SUFFIX=.exe install
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

xcopy /s /y /f "%TMP_PREFIX%" "%PREFIX%"
dir %PREFIX%\bin
