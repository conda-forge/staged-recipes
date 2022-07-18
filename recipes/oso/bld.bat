@echo on

cargo build -p polar-c-api

cd %SRC_DIR%/languages/python/oso

make build

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

%PYTHON% -m pip install .
