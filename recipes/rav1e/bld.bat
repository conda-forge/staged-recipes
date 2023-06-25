echo ON
cargo build --release
if errorlevel 1 exit 1
cargo install --path . --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

REM https://github.com/xiph/rav1e
cargo install cargo-c

REM Hmm, does conda-forge have cargo-c??
REM https://github.com/Homebrew/homebrew-core/blob/7d7fc5432ee7b16e7a7ce9f85951052f7ad55e96/Formula/rav1e.rb
cargo cinstall --library-type cdylib --release --prefix %LIBRARY_PREFIX%
if errorlevel 1 exit 1

cargo uninstall cargo-c
if errorlevel 1 exit 1
