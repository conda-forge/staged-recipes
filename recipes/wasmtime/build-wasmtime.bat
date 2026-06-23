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

if not defined CARGO_BUILD_TARGET (
    if "%target_platform%"=="win-arm64" (
        set "CARGO_BUILD_TARGET=aarch64-pc-windows-msvc"
    ) else if "%target_platform%"=="win-64" (
        set "CARGO_BUILD_TARGET=x86_64-pc-windows-msvc"
    )
)

if "%PKG_NAME%" == "libwasmtime" (
    cd wasmtime                                                                         || exit 20
    cargo build -p wasmtime-c-api --release                                             || exit 21
    dir /s "target\%CARGO_BUILD_TARGET%\release"
    copy "target\%CARGO_BUILD_TARGET%\release\wasmtime.dll" ^
        "%LIBRARY_BIN%"                                                                 || exit 22
    dir /s "%LIBRARY_BIN%"                                                              || exit 23
    cd crates\c-api                                                                     || exit 24
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml                         || exit 25
    :: emits exotic return codes, ignore and check
    robocopy include "%LIBRARY_INC%" /copyall
    robocopy include\wasmtime "%LIBRARY_INC%\wasmtime" /copyall
    dir /s "%LIBRARY_INC%"                                                              || exit 26
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

echo "unexpected package: %PKG_NAME%'"

exit 99
