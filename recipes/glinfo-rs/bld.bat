set CARGO_HOME=%CD%\.cargo
set CARGO_TERM_COLOR=always

cargo build --release
if errorlevel 1 exit 1

cargo install --path . --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

