#!/usr/bin/env bash
set -euo pipefail

# GIO's pkg-config file points to tools in the host prefix, not the build prefix.
printf "[binaries]\ngdbus-codegen = '%s/bin/gdbus-codegen'\ngio-querymodules = '%s/bin/gio-querymodules'\n" \
    "$BUILD_PREFIX" "$BUILD_PREFIX" > gio-tools.ini
machine_file=--native-file
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    machine_file=--cross-file
fi

read -r -a setup_args <<< "$MESON_ARGS"
meson setup build "${setup_args[@]}" "$machine_file" gio-tools.ini \
    --sysconfdir=/etc --libexecdir=libexec \
    -Dbash_completion=false -Dman=false -Dvapi=false
meson compile -C build

# DESTDIR skips the shared GIO module cache, which must not ship in this package.
stage="$SRC_DIR/stage"
DESTDIR="$stage" meson install -C build --no-rebuild
cp -a "$stage$PREFIX/." "$PREFIX/"
