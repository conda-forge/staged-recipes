#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make -j${CPU_COUNT} LD="${CC}" CC="${CC}" LDFLAGS="${LDFLAGS}" PREFIX=${PREFIX} install

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
install -m 644 autocomplete/complete.bash ${PREFIX}/etc/bash_completion.d/tldr
install -m 644 autocomplete/complete.zsh ${PREFIX}/share/zsh/site-functions/_tldr
install -m 644 autocomplete/complete.fish ${PREFIX}/share/fish/vendor_completions.d/tldr.fish
