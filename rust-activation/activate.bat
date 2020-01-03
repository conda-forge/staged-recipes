set CARGO_HOME=%CONDA_PREFIX%.cargo.win
set CARGO_CONFIG=%CARGO_HOME%\config
set RUSTUP_HOME=%CARGO_HOME%\rustup
set PATH=%CARGO_HOME%\bin:%PATH%

if not exist "%CARGO_HOME%" mkdir "%CARGO_HOME%"

echo [target.x86_64-pc-windows-msvc]>> %CARGO_CONFIG%
echo linker = "%LD%">> %CARGO_CONFIG%
