@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set "CMAKE_GENERATOR=NMake Makefiles"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% --no-default-features --features=native-tls || exit 1

cd py-rattler

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set py_rattler_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %py_rattler_wheel% -vv || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
