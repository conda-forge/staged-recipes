@echo on

:: crates\workspace\build.rs embeds these archives; it exits 1 with an explanatory
:: message if they are missing, but check here so a source layout change reads as a
:: recipe problem rather than a compile failure.
dir /b "%SRC_DIR%\.cache\sysml-stdlib-kpar-*\*.kpar" > nul || exit 1
dir /b "%SRC_DIR%\.cache\*.kpar" > nul || exit 1

:: rust-toolchain.toml pins an exact channel for upstream CI. It is a rustup feature and
:: is ignored by the bare cargo/rustc that the conda-forge rust compiler provides, so the
:: packaged toolchain is used regardless. Removed anyway to keep that explicit.
del /f /q rust-toolchain.toml

set CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %ERRORLEVEL% neq 0 exit 1

:: Two binaries from two workspace members: `spec42` from crates\server (the language
:: server and CLI, which is the only artifact upstream publishes) and `kpar-pack` from
:: crates\kpar. Installed under %LIBRARY_PREFIX% so they land in Library\bin, which is
:: on PATH in an activated environment.
cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path crates\server
if %ERRORLEVEL% neq 0 exit 1

cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path crates\kpar
if %ERRORLEVEL% neq 0 exit 1
