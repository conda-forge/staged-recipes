cargo build --release --locked --features tls-vendored
mkdir -p $PREFIX/bin
mv target/*/release/starship $PREFIX/bin/starship
