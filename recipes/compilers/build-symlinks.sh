#!/usr/bin/env bash
set -eu

cd "${PREFIX}/bin"
for fn in "${BUILD}-"*; do
    new_fn=${fn//${BUILD}-/}
    if [ ! -f "${new_fn}" ]; then
        echo "Creating symlink from ${fn} to ${new_fn}"
        ln -s "${fn}" "${new_fn}"
    fi
done
