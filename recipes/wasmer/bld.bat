:: NOTE: mostly derived from
:: https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/bld.bat
@echo on

cd lib/cli

:: build
cargo install --root "$PREFIX" --path . --features "cranelift llvm singlepass" || goto :error

:: move to scripts
md %SCRIPTS% || echo "%SCRIPTS% already exists"
move %PREFIX%\bin\wasmer.exe %SCRIPTS% || goto :error

:: install cargo-license and dump licenses
set CARGO_LICENSE_BIN=%BUILD_PREFIX%\.cargo\bin\cargo-license
set CARGO_LICENSES_FILE=%SRC_DIR%\%PKG_NAME%-%PKG_VERSION%-cargo-dependencies.json

cargo install --root "%BUILD_PREFIX%" cargo-license
%CARGO_LICENSE_BIN% --json > %CARGO_LICENSES_FILE%
dir %CARGO_LICENSES_FILE% || goto :error
:: TODO: remove this?
type %CARGO_LICENSES_FILE% || goto :error

:: remove extra build files
del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
