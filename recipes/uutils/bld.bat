for /f "usebackq tokens=*" %%i in (`cygpath %PREFIX%`) do set CONVERTED_PREFIX=%%i

cargo build --release --features windows
cargo install --path . --root "%PREFIX%" --features windows
make PROFILE=Release PREFIX="%CONVERTED_PREFIX%" MULTICALL=y PROG_SUFFIX=.exe install
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

dir %PREFIX%\bin
