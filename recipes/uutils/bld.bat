cargo build --release --features windows

cargo install --path . --root "%LIBRARY_PREFIX%" --features windows
make PROFILE=Release PREFIX="%CYGWIN_PREFIX%/Library" MULTICALL=y PROG_SUFFIX=.exe install

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

dir %PREFIX%\bin
