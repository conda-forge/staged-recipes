FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%\rust-nightly-install"') DO set "pfx=%%i"
bash %SRC_DIR%\rust-nightly\install.sh --verbose --prefix=%pfx% --disable-ldconfig --components=rustc,cargo,rust-std-x86_64-pc-windows-msvc
if errorlevel 1 exit 1

set "PATH=%SRC_DIR%\rust-nightly-install\bin;%PATH%"
set "CMAKE_GENERATOR=NMake Makefiles"
set "PYO3_PYTHON=%PYTHON%"
set "RUSTFLAGS=-C target-feature=+fxsr,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx,+fma"

maturin build --no-sdist --release --strip --manylinux off
if errorlevel 1 exit 1

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set polars_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %polars_wheel% -vv
