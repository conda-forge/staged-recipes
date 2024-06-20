@echo on

cd src\simplification\rdp

REM Bundle all downstream library licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY_LICENSES.yaml ^
    || goto :error

REM Build the Rust library
CARGO_INCREMENTAL="0" cargo build --release

REM Copy the built library to the Python package
cp include\header.h ..\
cp target\release\deps\rdp.dll.lib target\target\release\deps\rdp.lib
cp target\release\rdp* ..\
cp target\release\deps\rdp* ..\

REM Remove the build directory
cd %SRC_DIR%
rm -rf src\simplification\rdp

REM Build the Python package
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
