FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%\rust-nightly-install"') DO set "pfx=%%i"
bash %SRC_DIR%\rust-nightly\install.sh --verbose --prefix=%pfx% --disable-ldconfig --components=rustc,cargo,rust-std-x86_64-pc-windows-msvc
if errorlevel 1 exit 1

set "PATH=%SRC_DIR%\rust-nightly-install\bin;%PATH%"
set "CMAKE_GENERATOR=NMake Makefiles"

maturin build --no-sdist --release --strip --manylinux off --interpreter=%PYTHON% --rustc-extra-args="-C codegen-units=16 -C lto=thin -C target-cpu=native"
if errorlevel 1 exit 1

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set polars_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %polars_wheel% -vv
