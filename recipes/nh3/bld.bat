maturin build --release --strip --manylinux off --interpreter=%PYTHON% --out dist

FOR /F "delims=" %%i IN ('dir /s /b dist\*.whl') DO set nh3_wheel=%%i

%PYTHON% -m pip install --no-deps %nh3_wheel% -vv

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
