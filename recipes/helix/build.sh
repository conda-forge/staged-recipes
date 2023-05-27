#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit


cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

HELIX_LIBEXEC="$PREFIX"/libexec/helix
export HELIX_RUNTIME="$HELIX_LIBEXEC"/runtime

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path helix-term

# strip debug symbols
"$STRIP" "$PREFIX"/bin/hx

# create custom launcher
mv "$PREFIX"/bin/hx "$HELIX_LIBEXEC"/hx
echo -e '#!/bin/bash\nHELIX_RUNTIME="'"$HELIX_RUNTIME"'" exec "'"$HELIX_LIBEXEC"'"/hx "$@"' > "$PREFIX"/bin/hx
chmod +x "$PREFIX"/bin/hx

# remove extra build files
rm -f "$PREFIX"/.crates*
rm -rf "$HELIX_RUNTIME"/grammars/sources
rm -rf "$HELIX_RUNTIME"/grammars/*.dSYM

# copy runtime files
rm -rf runtime/grammars
cp -r runtime "$HELIX_LIBEXEC"
