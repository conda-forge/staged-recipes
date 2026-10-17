#!/usr/bin/env bash
# Usage: build_lwt.sh <lwt|lwt_ppx>
# Mirrors the opam build of lwt: the discover step runs first (libev disabled).
set -euxo pipefail

# dune's shared cache breaks on win (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

pkg="$1"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${pkg}" == "lwt" ]]; then
  dune exec -p lwt src/unix/config/discover.exe -- --save --use-libev false
fi

bash "${here}/build_dune_pkg.sh" "${pkg}"
