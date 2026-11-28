#!/usr/bin/env bash
set -euxo pipefail

if [[ -z "${MESON_ARGS:-}" ]]; then
  MESON_ARGS="-Dbuildtype=release --prefix=${PREFIX} -Dlibdir=lib"
fi

# shellcheck disable=SC2086
meson setup build ${MESON_ARGS} --wrap-mode=nodownload
meson compile -C build -j "${CPU_COUNT:-2}"
meson install -C build --no-rebuild
