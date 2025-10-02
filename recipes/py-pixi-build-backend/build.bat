@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set "TEMP_BUILD_DIR=%TEMP%\ppbb-%RANDOM%"
set "TEMP_CARGO_HOME=C:\ch-%RANDOM%"
mkdir "%TEMP_BUILD_DIR%"
mkdir "%TEMP_CARGO_HOME%"
set CARGO_TARGET_DIR=%TEMP_BUILD_DIR%
set CARGO_HOME=%TEMP_CARGO_HOME%

cd py-pixi-build-backend

%PYTHON% -m pip install --ignore-installed --no-deps . -vv

cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml