@echo on

:: The compiled Python extension lives in the py-geopolars crate, which is
:: deliberately excluded from the workspace at the repository root.
cd py-geopolars
if errorlevel 1 exit 1

:: Two crate versions pinned in Cargo.lock no longer build with a current rustc:
:: ethnum 1.3.0 fails with E0512 (transmute between differently sized types) and
:: geo-types 0.7.7 has a float literal that is now a hard parse error. Both are
:: semver-compatible bumps that the manifests already allow.
cargo update --package ethnum --precise 1.5.3
if errorlevel 1 exit 1
cargo update --package geo-types --precise 0.7.19
if errorlevel 1 exit 1

:: geozero pulls in prost-build unconditionally, and prost-build's own build
:: script insists on locating a protoc even though geozero only runs protobuf
:: codegen under its "with-mvt" feature, which is off here. Point it at the
:: protoc from libprotobuf so it does not build its vendored protobuf via cmake.
set "PROTOC=%BUILD_PREFIX%\Library\bin\protoc.exe"

cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if errorlevel 1 exit 1

maturin build --release --locked --jobs %CPU_COUNT% --out dist
if errorlevel 1 exit 1

for %%w in (dist\geopolars-*.whl) do (
    %PYTHON% -m pip install %%w --no-deps --no-build-isolation -vv
    if errorlevel 1 exit 1
)
