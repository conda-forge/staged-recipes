set -ex

cargo install --path . --root ${PREFIX}

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
