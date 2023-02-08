cargo build --release
mkdir -p $PREFIX/bin
cp target/release/typos $PREFIX/bin/
