set -ex

FEATURE_SET="unix"
if [[ "${target_platform}" == "osx"* ]]; then
    FEATURE_SET="macos"
fi

cargo build --release --features "${FEATURE_SET}"

cargo install --path . --root "${PREFIX}" --features "${FEATURE_SET}"
make PROFILE=Release PREFIX="${PREFIX}" PROG_SUFFIX= MULTICALL=y install

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
