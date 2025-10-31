export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .