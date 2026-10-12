#!/usr/bin/env bash
# Usage: build_topkg_pkg.sh [extra pkg.ml args...]
# Builds and installs one topkg-based OCaml library from ${SRC_DIR}/<name>,
# where <name> is the conda package name (${PKG_NAME}) without its "ocaml-" prefix.
# Identical across all ocaml-* recipes of this family.
set -euxo pipefail

NAME="${PKG_NAME#ocaml-}"

# shellcheck source=build_findlib.sh
source "$(dirname "${BASH_SOURCE[0]}")/build_findlib.sh"

# uucp: upstream warns ocamlopt may need an unlimited stack on arm64/ppc64
if [[ "${NAME}" == "uucp" ]]; then
  ulimit -s unlimited || true
fi

cd "${SRC_DIR}/${NAME}"

# pkg.ml does `#use "topfind"`; #use only searches the cwd, -I dirs and the
# stdlib dir, so point it at the private topfind copied by build_findlib.sh.
ocaml -I "${SRC_DIR}/_tools/toplevel" pkg/pkg.ml build --dev-pkg false "$@"

# opam-installer (from the conda-forge `opam` package) honours the .install file
opam-installer \
  --prefix="${OCAML_PREFIX}" \
  --libdir="${OCAML_PREFIX}/lib/ocaml" \
  --docdir="${OCAML_PREFIX}/share/doc" \
  "${NAME}.install"

# Docs are not needed in the package (LICENSE is handled by about.license_file)
rm -rf "${OCAML_PREFIX}/share/doc/${NAME}"
