#!/usr/bin/env bash
# Usage: build_lwt.sh <lwt|lwt_ppx>
# Mirrors the opam build of lwt: the discover step runs first (libev disabled).
set -euxo pipefail

# dune's shared cache breaks on win (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

pkg="$1"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Host libs (dune-configurator) live in the host prefix; win activation only lists BUILD_PREFIX.
if [[ "${OSTYPE:-}" == "msys" || "${OSTYPE:-}" == "cygwin" || "${target_platform:-}" == win-* ]]; then
  export OCAMLPATH="${PREFIX}/Library/lib/ocaml${OCAMLPATH:+;${OCAMLPATH}}"
else
  export OCAMLPATH="${PREFIX}/lib/ocaml${OCAMLPATH:+:${OCAMLPATH}}"
fi

if [[ "${pkg}" == "lwt" ]]; then
  dune exec -p lwt src/unix/config/discover.exe -- --save --use-libev false
fi

bash "${here}/build_dune_pkg.sh" "${pkg}"
