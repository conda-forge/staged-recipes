set CARGO_HOME=%CD%\.cargo
set CARGO_TERM_COLOR=always

cargo build --release
if errorlevel 1 exit 1

copy target\release\glinfo.exe %LIBRARY_BIN%
if errorlevel 1 exit 1
