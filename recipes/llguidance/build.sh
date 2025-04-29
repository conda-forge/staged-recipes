set -ex

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Optimize the Cargo build 
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
