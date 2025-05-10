set -ex

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# Optimize the Cargo build 
export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

pushd hf_xet
cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
# maturin build --release --features openssl_vendored
popd

# https://github.com/PyO3/maturin/issues/2489#issuecomment-2812021105
mkdir python
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
