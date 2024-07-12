@echo on

cargo-bundle-licenses --format yaml --output THIRDPARTY.yaml
if errorlevel 1 exit 1

python -m pip install . \
    --no-deps --ignore-installed -vv --no-build-isolation --disable-pip-version-check
if errorlevel 1 exit 1
