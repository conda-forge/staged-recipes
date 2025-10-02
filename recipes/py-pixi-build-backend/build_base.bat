@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: Navigate to the source 
cd py-pixi-build-backend

:: Avoid path length issues
set "TEMP_BUILD_DIR=%TEMP%\ppbb-%RANDOM%"
set "TEMP_CARGO_HOME=C:\ch-%RANDOM%"
mkdir "%TEMP_BUILD_DIR%"
mkdir "%TEMP_CARGO_HOME%"
set CARGO_TARGET_DIR=%TEMP_BUILD_DIR%
set CARGO_HOME=%TEMP_CARGO_HOME%

:: Build and install the package
set "CMAKE_GENERATOR=NMake Makefiles"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% || exit 1

:: Install the built wheel
FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set py_pixi_build_backend_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %py_pixi_build_backend_wheel% -vv || exit 1

:: Bundle licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
