@echo on

set "LLVM_SYS_201_PREFIX=%LIBRARY_PREFIX%"
set "MATURIN_PEP517_ARGS=--features llvm20-1 --features llvm-sys-201/prefer-dynamic"
set "MATURIN_STRIP=true"

if not exist "%LIBRARY_PREFIX%\lib\zstd.dll.lib" copy "%LIBRARY_PREFIX%\lib\zstd.lib" "%LIBRARY_PREFIX%\lib\zstd.dll.lib"
if errorlevel 1 exit /b 1

"%PYTHON%" -m pip install ./pyqir -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1

cargo-bundle-licenses --features "llvm20-1,llvm-sys-201/prefer-dynamic" --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1
