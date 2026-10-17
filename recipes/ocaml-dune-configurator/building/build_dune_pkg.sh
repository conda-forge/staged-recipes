#!/usr/bin/env bash
# Usage: build_dune_pkg.sh <opam-package>[,<opam-package>...]
# Builds and installs dune package(s) into the conda lib/ocaml tree.
set -euxo pipefail

pkgs="$1"

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
# Host libs (e.g. csexp) live in ${prefix}/lib/ocaml; win activation only lists BUILD_PREFIX.
export OCAMLPATH="${compat}${sep}${prefix}/lib/ocaml${OCAMLPATH:+${sep}${OCAMLPATH}}"

dune build -p "${pkgs}" --profile=release -j "${CPU_COUNT:-1}" @install
dune install -p "${pkgs}" --prefix="${prefix}" \
  --libdir="${prefix}/lib/ocaml" \
  --docdir="${prefix}/share/doc" \
  --mandir="${prefix}/share/man"
