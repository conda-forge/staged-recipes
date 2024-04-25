@echo off
REM Build
call maturin build --release --manifest-path=%SRC_DIR%quil-py\Cargo.toml --out wheels
call cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

call %PYTHON% -m pip install quil ^
  --no-build-isolation ^
  --no-deps ^
  --only-binary :all: ^
  --find-links=wheels/ ^
  --prefix %PREFIX%