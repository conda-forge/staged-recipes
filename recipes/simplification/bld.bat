@echo on

cd src\simplification\rdp

REM Bundle all downstream library licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY_LICENSES.yaml ^
    || goto :error

REM Build the Rust library
set TARGET=x86_64-pc-windows-msvc
cargo build --release --target=%TARGET% --features headers

REM Copy the built library to the Python package
copy target\%TARGET%\release\deps\rdp.dll.lib target\%TARGET%\release\deps\rdp.lib
copy target\%TARGET%\release\rdp* ..\
copy target\%TARGET%\release\deps\rdp* ..\
copy include\header.h ..\

REM Remove the build directory
cd %SRC_DIR%
rmdir /S /Q -rf src\simplification\rdp

REM Build the Python package
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
