maturin build --release --strip --manylinux off --interpreter=%PYTHON%

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set xorjson_wheel=%%i

%PYTHON% -m pip install --no-deps %xorjson_wheel% -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml