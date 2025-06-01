@echo off

:: Set Rust optimization flags
set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat
set CARGO_BUILD_JOBS=%CPU_COUNT%

:: Build with maturin
%PYTHON% -m maturin build --release --strip --interpreter %PYTHON% || goto :error
%PYTHON% -m pip install target\wheels\*.whl -vv --no-deps || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1