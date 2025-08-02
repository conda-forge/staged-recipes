set CARGO_HOME=%CD%\.cargo
set CARGO_TERM_COLOR=always

cargo install --path . --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

