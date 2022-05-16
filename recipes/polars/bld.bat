set "CMAKE_GENERATOR=NMake Makefiles"
maturin build --no-sdist --release --strip --manylinux off --interpreter=%PYTHON% --rustc-extra-args="-C codegen-units=16 -C lto=thin -C target-cpu=native"
if errorlevel 1 exit 1

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set polars_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %polars_wheel% -vv
