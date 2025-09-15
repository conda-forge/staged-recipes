set -e

export CARGO_HOME=$PWD/.cargo
export CARGO_TERM_COLOR=always

cargo install --path . --root $PREFIX

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

