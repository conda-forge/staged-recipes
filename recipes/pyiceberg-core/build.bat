@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set "CMAKE_GENERATOR=NMake Makefiles"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% --no-default-features || exit 1

cd bindings/python

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set pyiceberg_core_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %pyiceberg_core_wheel% -vv || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1