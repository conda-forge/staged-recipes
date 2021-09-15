cargo install --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/tango-controls-tui"

# remove extra build file
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
