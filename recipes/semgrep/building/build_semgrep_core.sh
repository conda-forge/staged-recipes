#!/usr/bin/env bash
# Build semgrep-core with dune inside a workspace holding the vendored duniverse.
set -euxo pipefail

# dune's shared cache breaks on non-unix (mkdir_p on a mixed-slash cache root).
export DUNE_CACHE=disabled

T="${SRC_DIR}/_tools"
if [[ "${OS:-}" == "Windows_NT" || "${OSTYPE:-}" == "msys" || "${OSTYPE:-}" == "cygwin" || "${target_platform:-}" == win-* ]]; then
  prefix="${PREFIX}/Library"; sep=';'; exe=.exe
else
  prefix="${PREFIX}"; sep=':'; exe=
fi
# forward-slash variants: findlib.conf, dune and gcc reject backslashes
src="${SRC_DIR//\\//}"
tf="${T//\\//}"
pf="${prefix//\\//}"

# edit PERL_EXPR VERIFY_EXPR FILE...: perl -pi, then fail unless the perl -ne VERIFY_EXPR exits 0 ('' skips it)
edit() {
  local expr="$1" verify="$2"
  shift 2
  perl -pi -e "${expr}" "$@"
  if [[ -n "${verify}" ]]; then perl -ne "${verify}" "$@"; fi
}

# --- findlib: conda's ocaml-findlib (build env) on unix, a private build on non-unix ---
mkdir -p "${T}/etc" "${T}/lib" "${T}/toplevel"
if [[ -n "${exe}" ]]; then
  pushd "${SRC_DIR}/findlib"
    ./configure \
      -bindir "${T}/bin" \
      -sitelib "${T}/lib" \
      -mandir "${T}/man" \
      -config "${T}/etc/findlib.conf" \
      -no-custom \
      -no-topfind
    make all
    make opt
    make install
    cp src/findlib/topfind "${T}/toplevel/topfind"
  popd
  export PATH="${T}/bin:${PATH}"
  findlib_extra=""
else
  cp "${BUILD_PREFIX}/lib/ocaml/topfind" "${T}/toplevel/topfind"
  # conda's findlib keeps its own META under site-lib
  findlib_extra="${sep}${BUILD_PREFIX}/lib/ocaml/site-lib"
fi

# Search conda's OCaml tree, then the private tree (num, zarith), then the stdlib.
stdlib="$(ocamlc -where | tr -d '\r')"
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${pf}/lib/ocaml"
path="${pf}/lib/ocaml${sep}${tf}/lib${sep}${stdlib//\\//}${findlib_extra}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"

# --- Private (never installed) non-dune deps: num, zarith -> ${T}/lib -------
export OCAMLFIND_DESTDIR="${T}/lib"

pushd "${SRC_DIR}/nondune/num"
  make
  # Plain `install` is legacy mode (writes into the stdlib dir), so install via ocamlfind.
  # ocamlfind treats a ./META.num next to the Makefile as already installed: move the generated one away.
  mv src/META.num src/META.num-gen
  # non-unix make's shell keeps the single quotes from the echo'd META.num (and may add BOM/CR); grep is absent there.
  edit "s/^\xEF\xBB\xBF//; s/\s+\z//; s/^\s*'//; s/'\s*\z//; \$_ .= qq(\n)" \
    'exit 1 if /\x27/ || /\r/' src/META.num-gen
  edit 's/^\tcp META\.num META\r?$/\tcp META.num-gen META/' '' src/Makefile
  # num-top is unused and its META.top echo keeps quotes on non-unix
  edit 's/^findlib-install: num-top-install\s*$/findlib-install:\n/' \
    '$c++ if /^\tcp META\.num-gen META/; exit 1 if /^findlib-install: num-top-install/; END { exit 1 unless $c }' \
    src/Makefile
  make findlib-install
popd

pushd "${SRC_DIR}/nondune/zarith"
  CFLAGS="${CFLAGS:-} -I${pf}/include" \
  LDFLAGS="${LDFLAGS:-} -L${pf}/lib" \
  ./configure
  if [[ -n "${exe}" ]]; then
    # configure records backslash paths (ocamlc -where, pkg-config) and gcc then misses gmp.h.
    # Keep line-end continuations (Makefile includes project.mak).
    perl -pi -e 's{\\(?![\r\n])}{/}g' Makefile
  fi
  make
  make install
popd
unset OCAMLFIND_DESTDIR

# seq is in the stdlib; opam's seq.base only installs this empty META so `(libraries seq)` resolves.
mkdir -p "${T}/lib/seq"
cat > "${T}/lib/seq/META" <<'EOF'
version = "[distributed with OCaml 4.07 or above]"
description = "dummy backward-compatibility package for iterators"
requires = ""
EOF

export OCAMLPATH="${T}/lib${sep}${prefix}/lib/ocaml"

source "${RECIPE_DIR}/building/hidden_private_builds.sh"  # HIDDEN(#35158)

export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig${sep}${prefix}/share/pkgconfig${PKG_CONFIG_PATH:+${sep}${PKG_CONFIG_PATH}}"

# Dynamic linking: makes src/main/flags.sh emit no static/brew flags.
export FORCE_DYNLINK=true
# Per-grammar C stubs read these (default /usr/local).
export TREESITTER_INCDIR="${prefix}/include"
export TREESITTER_LIBDIR="${prefix}/lib"

if [[ -n "${exe}" ]]; then
  # conda's non-unix libtree-sitter/pcre2 are MSVC builds (no tree-sitter.pc), but flexlink (MinGW)
  # wants lib<name>.dll.a: make import libs from the DLLs in a private dir.
  implib="${tf}/implib"
  mkdir -p "${implib}/pkgconfig"
  for lib in tree-sitter pcre2-8; do
    dll="${pf}/bin/${lib}.dll"
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
Cflags: -I${pf}/include
EOF
  export PKG_CONFIG_PATH="${implib}/pkgconfig${sep}${PKG_CONFIG_PATH}"
  export TREESITTER_LIBDIR="${implib}"
  # Bare -l flags (pcre2-ocaml, grammar stubs) need the search dir; the grammars' scanner.o and
  # libstdc++.dll.a both define std::string members, so let the first definition win.
  export FLEXLINKFLAGS="${FLEXLINKFLAGS:+${FLEXLINKFLAGS} }-L${implib} -link -Wl,--allow-multiple-definition"
fi
pkg-config --exists --print-errors tree-sitter

cd "${SRC_DIR}/semgrep"

if [[ -n "${exe}" ]]; then
  # Tarball symlinks come out broken on non-unix: copy file links (two passes for chained links).
  # Directory links are left alone: dune does not need them.
  for pass in 1 2; do
    while IFS= read -r l; do
      t="$(dirname "${l}")/$(readlink "${l}")"
      if [[ -f "${t}" ]]; then rm -f "${l}"; cp "${t}" "${l}"; fi
    done < <(find . -path ./duniverse -prune -o -type l -print)
  done
  test -f src/configuring/Rule_options.atd && ! test -L src/configuring/Rule_options.atd
fi

# The root `dune` limits scanned dirs: add duniverse and mark it vendored (warnings never fail the build).
# Not via duniverse/dune: that path is the vendored dune tarball.
perl -pi -e 's/^([[:space:]]*)cli$/$&\n$1duniverse/' dune
grep -qx '[[:space:]]*duniverse' dune
printf '\n(vendored_dirs duniverse)\n' >> dune

# eio_linux needs ocaml-uring (struct statx, glibc >= 2.28; sysroot is 2.17); eio_main falls back to eio_posix.
rm -rf duniverse/eio/lib_eio_linux

# The dune-configurator copy comes from $T/lib (HIDDEN(#35158): later the host package); drop the vendored one.
rm -rf duniverse/dune/otherlibs/configurator

# iomux stubs hardcode -Werror; osx clang then fails on the unused -L$BUILD_PREFIX/lib from :standard.
edit 's/\x22-Werror\x22//' 'exit 1 if /\x22-Werror\x22/' duniverse/ocaml-iomux/lib/dune

if [[ -n "${exe}" ]]; then
  # -Wl,-rpath in c_library_flags reaches gcc as a bare -rpath via flexlink, which MinGW rejects.
  edit '$_ = "" if /^\s*-Wl,-rpath,/' 'exit 1 if /^\s*-Wl,-rpath,/' languages/*/tree-sitter/*/lib/dune
  # ANSITerminal: caml_raise_with_args needs <caml/fail.h> (implicit declaration is an error in gcc >= 14).
  # Add it after #define CAML_INTERNALS, in the file dune copies to ANSITerminal_stubs.c.
  ansi=duniverse/ANSITerminal/src
  edit 's{^(#include <caml/callback\.h>\r?\n)}{$1#include <caml/fail.h>\n}' \
    '$c++ if /^#include <caml\/fail\.h>/; END { exit 1 unless $c == 1 }' "${ansi}/ANSITerminal_win_stubs.c"
  # FillConsoleOutputCharacterA gets an int* for LPDWORD (both 32-bit on non-unix).
  edit 's/\(names ANSITerminal_stubs\)/(names ANSITerminal_stubs) (flags (:standard -Wno-error=incompatible-pointer-types))/' \
    '$c++ if /\(flags \(:standard -Wno-error=incompatible-pointer-types\)\)/; END { exit 1 unless $c }' "${ansi}/dune"
  # parmap: `long len` is passed as intnat* (long is 32-bit, intnat 64-bit on non-unix).
  edit 's/\blong(\s+len\b)/intnat$1/g' \
    '$c++ if /\bintnat\s+len\b/; exit 1 if /\blong\s+len\b/; END { exit 1 unless $c }' duniverse/parmap/src/bytearray_stubs.c
fi

# pecu's tarball has test files with ':' in names (not creatable on non-unix): the recipe keeps the
# .tbz packed; unpack it without test/ (build-env python; $PYTHON is the host one).
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
test -f "${pecu_dir}/dune-project"

# Same target as upstream `make core`; not `-p semgrep` (hides vendored pkgs) and not @install (needs cargo).
# src/git_info/dune would fall back to `git rev-parse HEAD` of the enclosing checkout: pin the v${PKG_VERSION} commit (SEMGREP_GIT_COMMIT from recipe.yaml).
export SEMGREP_GIT_COMMIT

# dune names executables <name>.exe on non-unix; the install-tree target follows.
dune build --profile=release -j "${CPU_COUNT:-2}" "./_build/install/default/bin/semgrep-core${exe}"

mkdir -p "${prefix}/bin"
install -m 0755 "_build/install/default/bin/semgrep-core${exe}" "${prefix}/bin/semgrep-core${exe}"

# License files of everything linked in -> ${SRC_DIR}/vendored-licenses/<same relative dir>/.
# Plain globs here match one path segment per `*`; recipe license_file globs would recurse into _build/ and tests.
lic="${src}/vendored-licenses"
mkdir -p "${lic}"
nlic=0
shopt -s nullglob nocaseglob
for f in \
    "${src}"/semgrep/duniverse/*/{LICENSE,LICENCE,COPYING,COPYRIGHT}* \
    "${src}"/nondune/*/{LICENSE,LICENCE,COPYING,COPYRIGHT}* \
    "${src}"/findlib/{LICENSE,LICENCE,COPYING,COPYRIGHT}* \
    "${src}"/semgrep/libs/*/{LICENSE,license.txt,copyright.txt} \
    "${src}"/semgrep/libs/ocaml-tree-sitter-semgrep/core/LICENSE \
    "${src}"/semgrep/languages/*/menhir/{*license*.txt,copyright.txt} \
    "${src}"/semgrep/languages/*/tree-sitter/*/fyi/semgrep-grammars/src/*/{LICENSE,COPYING}*; do
  [[ -f "${f}" && -s "${f}" ]] || continue
  rel="${f#"${src}/"}"
  mkdir -p "${lic}/$(dirname "${rel}")"
  cp "${f}" "${lic}/${rel}"
  nlic=$((nlic + 1))
done
shopt -u nullglob nocaseglob
echo "collected ${nlic} license files"
[[ "${nlic}" -ge 100 ]] || { echo "too few license files collected" >&2; exit 1; }
