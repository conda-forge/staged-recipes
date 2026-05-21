@echo on

rem ── Remove .cargo/config.toml that hardcodes system paths ──────────
if exist .cargo\config.toml del .cargo\config.toml

rem ── Third-party license bundling (conda-forge requirement for Rust) ─
cargo-bundle-licenses --format yaml --output THIRDPARTY.yaml
if errorlevel 1 exit 1

rem ── Build the wheel (CPU only on Windows; CUDA builds are skipped) ──
set FEATURES=extension-module

rem ── chemfiles: point at conda-forge prefix ─────────────────────────
set "CHEMFILES_DIR=%LIBRARY_PREFIX%"
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;%PKG_CONFIG_PATH%"

maturin build ^
    --release ^
    --strip ^
    --interpreter "%PYTHON%" ^
    --no-default-features ^
    --features %FEATURES% ^
    --out dist
if errorlevel 1 exit 1

rem ── Install ─────────────────────────────────────────────────────────
for %%f in (dist\warp_md-*.whl) do (
    "%PYTHON%" -m pip install "%%f" --no-deps --no-build-isolation -vv
    if errorlevel 1 exit 1
)
