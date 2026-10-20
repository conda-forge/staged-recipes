#!/usr/bin/env bash
# Build semgrep-core with dune inside a workspace holding the vendored duniverse.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root); keep builds hermetic.
export DUNE_CACHE=disabled

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
  # num's Makefile echo's META.num line by line; non-unix make's shell keeps the single
  # quotes (and may leave a BOM/trailing blanks/CR). Strip them; grep is absent on non-unix.
  perl -pi -e "s/^\xEF\xBB\xBF//; s/\s+\z//; s/^\s*'//; s/'\s*\z//; \$_ .= qq(\n)" src/META.num-gen
  perl -ne 'chomp(my $l = $_); print "META.num-gen: [$l]\n"; exit 1 if /\x27/ || /\r/' src/META.num-gen
  perl -pi -e 's/^\tcp META\.num META\r?$/\tcp META.num-gen META/' src/Makefile
  # non-unix make shell keeps quotes in echo'd META.top; num-top unused
  perl -pi -e 's/^findlib-install: num-top-install\s*$/findlib-install:\n/' src/Makefile
  perl -ne '$c++ if /^\tcp META\.num-gen META/; exit 1 if /^findlib-install: num-top-install/; END { exit 1 unless $c }' src/Makefile
  make findlib-install
popd

pushd "${SRC_DIR}/nondune/zarith"
  if [[ "${target_platform:-}" == win-* ]]; then
    zinc="${PREFIX//\\//}/Library/include"; zlib="${PREFIX//\\//}/Library/lib"
  else
    zinc="${PREFIX}/include"; zlib="${PREFIX}/lib"
  fi
  CFLAGS="${CFLAGS:-} -I${zinc}" \
  LDFLAGS="${LDFLAGS:-} -L${zlib}" \
  ./configure
  if [[ "${target_platform:-}" == win-* ]]; then
    # configure records backslash paths (ocamlc -where, pkg-config) and gcc then
    # misses gmp.h; use forward slashes.
    [[ -f Makefile ]] || { ls; exit 1; }
    # zarith's configure generates Makefile (which includes project.mak); keep EOL continuations
    perl -pi -e 's{\\(?![\r\n])}{/}g' Makefile
    perl -ne 'print "Makefile: $_"' Makefile
  fi
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

if [[ "${OSTYPE:-}" == "msys" || "${OSTYPE:-}" == "cygwin" || "${target_platform:-}" == win-* ]]; then
  prefix="${PREFIX}/Library"; sep=';'; exe=.exe
else
  prefix="${PREFIX}"; sep=':'; exe=
fi
export OCAMLPATH="${T}/lib${sep}${prefix}/lib/ocaml"
export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig${sep}${prefix}/share/pkgconfig${PKG_CONFIG_PATH:+${sep}${PKG_CONFIG_PATH}}"

# Dynamic linking: makes src/main/flags.sh emit no static/brew flags.
export FORCE_DYNLINK=true
# Per-grammar C stubs read these (default /usr/local); point at conda tree-sitter.
export TREESITTER_INCDIR="${prefix}/include"
export TREESITTER_LIBDIR="${prefix}/lib"

if [[ -n "${exe}" ]]; then
  # conda's non-unix libtree-sitter and pcre2 are MSVC builds (tree-sitter.lib, pcre2-8.lib;
  # no tree-sitter.pc), but flexlink (MinGW) resolves -l<name> to lib<name>.dll.a. Make MinGW
  # import libs from the DLLs into a private dir and point -L / pkg-config at it.
  implib="${SRC_DIR//\\//}/_tools/implib"
  mkdir -p "${implib}/pkgconfig"
  for lib in tree-sitter pcre2-8; do
    dll="${prefix//\\//}/bin/${lib}.dll"
    test -f "${dll}"
    "${OBJDUMP:-x86_64-w64-mingw32-objdump}" -p "${dll}" | perl -ne '
      BEGIN { print "EXPORTS\n" }
      if (/\[Ordinal\/Name Pointer\] Table/) { $in = 1; next }
      if ($in) { if (/^\s*\[\s*\d+\].*\s(\S+)\s*$/) { print "$1\n"; $n++ } elsif (/^\s*$/ && $n) { $in = 0 } }
      END { exit 1 unless $n }' > "${implib}/${lib}.def"
    "${DLLTOOL:-x86_64-w64-mingw32-dlltool}" -d "${implib}/${lib}.def" -D "${lib}.dll" -l "${implib}/lib${lib}.dll.a"
    test -s "${implib}/lib${lib}.dll.a"
  done
  cat > "${implib}/pkgconfig/tree-sitter.pc" <<EOF
Name: tree-sitter
Description: tree-sitter runtime (MinGW import lib made by build_semgrep_core.sh)
Version: 0.27
Libs: -L${implib} -ltree-sitter
Cflags: -I${prefix//\\//}/include
EOF
  export PKG_CONFIG_PATH="${implib}/pkgconfig${sep}${PKG_CONFIG_PATH}"
  export TREESITTER_LIBDIR="${implib}"
  # pcre2-ocaml and the grammar stubs pass bare -l flags; give flexlink the search dir.
  # The grammar scanner.o files carry inline std::string members that libstdc++.dll.a
  # (pulled in by the grammars' -lstdc++) also exports; ld then reports multiple
  # definitions when linking semgrep-core.exe, so let the first definition win.
  export FLEXLINKFLAGS="${FLEXLINKFLAGS:+${FLEXLINKFLAGS} }-L${implib} -link -Wl,--allow-multiple-definition"
fi
pkg-config --exists --print-errors tree-sitter

cd "${SRC_DIR}/semgrep"

if [[ -n "${exe}" ]]; then
  # tarball symlinks (src/*.atd -> interfaces/, scanner.h, ...) come out broken on non-unix;
  # replace each one that points at a regular file with a copy. Directory links (grammar
  # trees under libs/ocaml-tree-sitter-semgrep/lang) are left alone: dune does not need them
  # and their trees hold dangling links. Two passes for file links that go through other links.
  for pass in 1 2; do
    while IFS= read -r l; do
      t="$(dirname "${l}")/$(readlink "${l}")"
      if [[ -f "${t}" ]]; then rm -f "${l}"; cp "${t}" "${l}"; fi
    done < <(find . -path ./duniverse -prune -o -type l -print)
  done
  test -f src/configuring/Rule_options.atd && ! test -L src/configuring/Rule_options.atd
fi

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

# iomux stubs hardcode -Werror; on osx clang warns that -L$BUILD_PREFIX/lib (from
# :standard) is unused when compiling only, which fails the build.
perl -pi -e 's/\x22-Werror\x22//' duniverse/ocaml-iomux/lib/dune
perl -ne 'exit 1 if /\x22-Werror\x22/' duniverse/ocaml-iomux/lib/dune

if [[ -n "${exe}" ]]; then
  # cairo and move_on_sui grammars add -Wl,-rpath,... to c_library_flags; flexlink hands it
  # to gcc as a bare -rpath, which the MinGW driver rejects. Drop it (comments mention rpath too).
  perl -pi -e '$_ = "" if /^\s*-Wl,-rpath,/' languages/*/tree-sitter/*/lib/dune
  perl -ne 'exit 1 if /^\s*-Wl,-rpath,/' languages/*/tree-sitter/*/lib/dune
  # ANSITerminal: caml_raise_with_args is used without <caml/fail.h> (implicit declaration
  # is an error in gcc >= 14), and FillConsoleOutputCharacterA gets an int* for LPDWORD
  # (both 32-bit on non-unix). The dune rule copies ANSITerminal_win_stubs.c to
  # ANSITerminal_stubs.c, so add the include there, after its #define CAML_INTERNALS
  # (a -include would precede that define and leave CAMLalloc_point_here undefined).
  ansi=duniverse/ANSITerminal/src
  perl -pi -e 's{^(#include <caml/callback\.h>\r?\n)}{$1#include <caml/fail.h>\n}' "${ansi}/ANSITerminal_win_stubs.c"
  perl -ne '$c++ if /^#include <caml\/fail\.h>/; END { exit 1 unless $c == 1 }' "${ansi}/ANSITerminal_win_stubs.c"
  perl -pi -e 's/\(names ANSITerminal_stubs\)/(names ANSITerminal_stubs) (flags (:standard -Wno-error=incompatible-pointer-types))/' "${ansi}/dune"
  perl -ne '$c++ if /\(flags \(:standard -Wno-error=incompatible-pointer-types\)\)/; END { exit 1 unless $c }' "${ansi}/dune"
  # parmap: `long len` is passed as intnat* (long is 32-bit, intnat 64-bit on non-unix).
  perl -pi -e 's/\blong(\s+len\b)/intnat$1/g' duniverse/parmap/src/bytearray_stubs.c
  perl -ne '$c++ if /\bintnat\s+len\b/; exit 1 if /\blong\s+len\b/; END { exit 1 unless $c }' duniverse/parmap/src/bytearray_stubs.c
fi

# pecu's tarball has test files with ':' in names (not creatable on non-unix), so the recipe
# keeps the .tbz unextracted; unpack it here without test/ (build-env python; $PYTHON is the host one).
pecu_dir=duniverse/pecu
python - "${pecu_dir}/pecu-0.7.tbz" "${pecu_dir}" <<'EOF'
import sys, tarfile
src, dest = sys.argv[1:3]
with tarfile.open(src) as t:
    for m in t.getmembers():
        parts = m.name.split("/", 1)
        m.name = parts[1] if len(parts) > 1 else ""
        if not m.name or m.name.startswith("test") or ":" in m.name:
            continue
        t.extract(m, dest)
EOF
mv "${pecu_dir}/pecu-0.7.tbz" "${SRC_DIR}/pecu-0.7.tbz.done"
test -f "${pecu_dir}/dune-project" || exit 1

# Same target as upstream `make core`. Not `-p semgrep` (hides vendored pkgs)
# and not @install (in-tree tree-sitter package install needs cargo).
# TODO(verify): upstream also runs `dune build libs/ocaml-tree-sitter-semgrep/core/tree-sitter-out`
# first; patch 0004 should make that unnecessary.
# src/git_info/dune falls back to `git rev-parse HEAD`, which walks up into the
# enclosing checkout; pin it to the upstream v${PKG_VERSION} tag commit.
export SEMGREP_GIT_COMMIT=a35fe8306115b3e55274969098cc46f8451d6b4d

# dune names executables <name>.exe on non-unix; the install-tree target follows.
dune build --profile=release -j "${CPU_COUNT:-2}" "./_build/install/default/bin/semgrep-core${exe}"

mkdir -p "${prefix}/bin"
install -m 0755 "_build/install/default/bin/semgrep-core${exe}" "${prefix}/bin/semgrep-core${exe}"
