@echo on
set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set CARGO_HOME=C:\.cargo

md %CARGO_HOME%

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation --disable-pip-version-check ^
    || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml ^
    || exit 1
