set -ex

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
