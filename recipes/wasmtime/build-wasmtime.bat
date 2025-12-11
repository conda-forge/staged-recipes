@echo on

if "%PKG_NAME%" == "python-wasmtime" (
    cd wasmtime-py                                                                      || exit 1
    python -m pip install . --no-deps --no-build-isolation --disable-pip-version-check  || exit 2
    exit 0
)

set CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
set CARGO_PROFILE_RELEASE_LTO=true
set CARGO_PROFILE_RELEASE_OPT_LEVEL=s
set CARGO_PROFILE_RELEASE_PANIC=abort
set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_TARGET_DIR=target

if "%PKG_NAME%" == "libwasmtime" (
    cd wasmtime                                                                         || exit 20
    cargo build -p wasmtime-c-api --release                                             || exit 21
    md "%LIBRARY_LIB%" "%LIBRARY_INC%"                                                  || exit 22
    copy target\*\release\libwasmtime%SHLIB_EXT% "%PREFIX%/lib"                         || exit 23
    cd crates\c-api                                                                     || exit 24
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml                         || exit 25
    cd include                                                                          || exit 26
    copy *.h ^
        *.hh ^
        wasmtime ^
        "%LIBRARY_INC%"                                                                 || exit 27
    exit 0
)

if "%PKG_NAME%" == "wasmtime" (
    cd wasmtime                                                                         || exit 40
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml                         || exit 41
    cargo install ^
        --no-track ^
        --locked ^
        --profile release ^
        --root "%PREFIX%" ^
        --path .                                                                        || exit 42
    exit 0
)

echo "unexpected %PKG_NAME%"

exit 99
