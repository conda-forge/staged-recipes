cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/nbwipers"

# remove extra build file
rm -f "${PREFIX}/.crates.toml"
