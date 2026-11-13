@echo on
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

pushd crates\lance-csr-python || exit 1
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml" || exit 1
popd || exit 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation || exit 1
