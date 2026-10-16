#!/usr/bin/env bash
# Build semgrep-core with dune inside a workspace holding the vendored duniverse.
set -euxo pipefail

# shellcheck source=/dev/null
source "${RECIPE_DIR}/building/build_findlib.sh"
T="${SRC_DIR}/_tools"

# --- Private (never installed) non-dune deps: num, zarith -> ${T}/lib -------
export OCAMLFIND_DESTDIR="${T}/lib"

pushd "${SRC_DIR}/nondune/num"
  make
  # findlib-install: everything via ocamlfind into OCAMLFIND_DESTDIR (plain
  # `install` is legacy mode and writes into the OCaml stdlib dir).
  # With no metadir configured, `ocamlfind install num` treats ./META.num as
  # "already installed" (frontend.ml: Filename.concat "" "META.num"), and
  # src/ holds the generated META.num, so move it out of the way first.
  mv src/META.num src/META.num-gen
  perl -pi -e 's/^\tcp META\.num META$/\tcp META.num-gen META/' src/Makefile
  make findlib-install
popd

pushd "${SRC_DIR}/nondune/zarith"
  CFLAGS="${CFLAGS:-} -I${PREFIX}/include" \
  LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib" \
  ./configure
  make
  make install
popd
unset OCAMLFIND_DESTDIR

# seq is in the stdlib since OCaml 4.07; opam's seq.base only installs this
# empty META so `(libraries seq)` resolves. Provide it privately in ${T}/lib.
mkdir -p "${T}/lib/seq"
cat > "${T}/lib/seq/META" <<'EOF'
version = "[distributed with OCaml 4.07 or above]"
description = "dummy backward-compatibility package for iterators"
requires = ""
EOF

export OCAMLPATH="${T}/lib:${PREFIX}/lib/ocaml"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

# Dynamic linking: makes src/main/flags.sh emit no static/brew flags.
export FORCE_DYNLINK=true
# Per-grammar C stubs read these (default /usr/local); point at conda tree-sitter.
export TREESITTER_INCDIR="${PREFIX}/include"
export TREESITTER_LIBDIR="${PREFIX}/lib"

cd "${SRC_DIR}/semgrep"

# The root `dune` limits scanned dirs to (dirs libs languages src tools cli):
# add duniverse and mark it vendored (inherited by every duniverse/<pkg>, so
# warnings in vendored code never fail the build). Not via duniverse/dune: that
# path is the vendored dune tarball (dune-configurator).
perl -pi -e 's/^([[:space:]]*)cli$/$&\n$1duniverse/' dune
grep -qx '[[:space:]]*duniverse' dune
printf '\n(vendored_dirs duniverse)\n' >> dune

# eio_linux needs ocaml-uring, which needs struct statx (glibc >= 2.28; the
# linux sysroot is 2.17). Without it eio_main selects the eio_posix backend.
rm -rf duniverse/eio/lib_eio_linux

# dune-configurator is provided by host ocaml-dune-configurator; drop the
# vendored copy to avoid two copies.
rm -rf duniverse/dune/otherlibs/configurator

# Same target as upstream `make core`. Not `-p semgrep` (hides vendored pkgs)
# and not @install (in-tree tree-sitter package install needs cargo).
# TODO(verify): upstream also runs `dune build libs/ocaml-tree-sitter-semgrep/core/tree-sitter-out`
# first; patch 0004 should make that unnecessary.
# src/git_info/dune falls back to `git rev-parse HEAD`, which walks up into the
# enclosing checkout; pin it to the upstream v${PKG_VERSION} tag commit.
export SEMGREP_GIT_COMMIT=a35fe8306115b3e55274969098cc46f8451d6b4d

dune build --profile=release -j "${CPU_COUNT:-2}" ./_build/install/default/bin/semgrep-core

mkdir -p "${PREFIX}/bin"
install -m 0755 _build/install/default/bin/semgrep-core "${PREFIX}/bin/semgrep-core"
