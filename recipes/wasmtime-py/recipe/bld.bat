@echo on

REM # build bindgen directory
cd rust
cargo build --release -p bindgen --target wasm32-wasip1
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd ..

REM # build the wasm component
cargo install wasm-tools
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM # Set cargo path based on conda's BUILD_PREFIX
SET CARGO_BIN=%BUILD_PREFIX%\.cargo.win\bin
SET PATH=%CARGO_BIN%;%PATH%

REM # Verify wasm-tools is available
where wasm-tools
if %ERRORLEVEL% neq 0 (
    echo wasm-tools not found in PATH, trying direct path
    SET WASM_TOOLS=%CARGO_BIN%\wasm-tools.exe
    if not exist "%WASM_TOOLS%" (
        echo wasm-tools executable not found at %WASM_TOOLS%
        exit /b 1
    )
    "%WASM_TOOLS%" component new .\rust\target\wasm32-wasip1\release\bindgen.wasm --adapt wasi_snapshot_preview1=.\ci\wasi_snapshot_preview1.reactor.wasm -o .\rust\target\component.wasm
) else (
    wasm-tools component new .\rust\target\wasm32-wasip1\release\bindgen.wasm --adapt wasi_snapshot_preview1=.\ci\wasi_snapshot_preview1.reactor.wasm -o .\rust\target\component.wasm
)
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

REM # bootstrapping with native platform
cd rust
cargo run -p=bindgen --features=cli .\target\component.wasm ..\wasmtime\bindgen\generated
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd ..

set "PROD=1"
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
