#!/usr/bin/env bash
# Usage: build.sh <lwt|lwt_ppx>
# Mirrors the opam build of lwt: the discover step runs first (libev disabled).
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

pkg="$1"

if [[ "${OSTYPE:-}" == "msys" || "${OSTYPE:-}" == "cygwin" || "${target_platform:-}" == win-* ]]; then
  prefix="${PREFIX}/Library"
else
  prefix="${PREFIX}"
fi

# No findlib on conda-forge; dune resolves findlib compat names (e.g. bytes) only via META.
compat="${SRC_DIR}/_ocaml_compat"
for name in bytes; do
  mkdir -p "${compat}/${name}"
  cat > "${compat}/${name}/META" <<'EOF'
version = "[distributed with OCaml]"
description = "Compatibility placeholder (stdlib since OCaml 4.02)"
requires = ""
EOF
done
if [[ "${prefix}" == */Library ]]; then sep=';'; else sep=':'; fi
# Host libs (dune-configurator) live in ${prefix}/lib/ocaml; non-unix activation only lists BUILD_PREFIX.
export OCAMLPATH="${compat}${sep}${prefix}/lib/ocaml${OCAMLPATH:+${sep}${OCAMLPATH}}"

if [[ "${pkg}" == "lwt" ]]; then
  dune exec -p lwt src/unix/config/discover.exe -- --save --use-libev false
fi

dune build -p "${pkg}" --profile=release -j "${CPU_COUNT:-1}" @install
dune install -p "${pkg}" --prefix="${prefix}" \
  --libdir="${prefix}/lib/ocaml" \
  --docdir="${prefix}/share/doc" \
  --mandir="${prefix}/share/man"
