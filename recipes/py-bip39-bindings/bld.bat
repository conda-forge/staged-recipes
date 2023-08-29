
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

%PYTHON% -m pip install --no-deps --ignore-installed . -vvv
