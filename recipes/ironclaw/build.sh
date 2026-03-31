#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
   cargo auditable install --no-track --locked --root "$PREFIX" --path . --target "$CARGO_BUILD_TARGET"
else
   cargo auditable install --no-track --locked --root "$PREFIX" --path .
fi

mkdir -p "$PREFIX/etc/bash_completion.d"
$PREFIX/bin/ironclaw completion --shell bash > $PREFIX/etc/bash_completion.d/ironclaw
mkdir -p "$PREFIX/share/zsh/site-functions"
$PREFIX/bin/ironclaw completion --shell zsh > $PREFIX/share/zsh/site-functions/_ironclaw
mkdir -p "$PREFIX/share/fish/vendor_completions.d"
$PREFIX/bin/ironclaw completion --shell fish > $PREFIX/share/fish/vendor_completions.d/ironclaw.fish
