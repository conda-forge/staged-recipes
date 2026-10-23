#!/usr/bin/env bash
# Usage: build.sh [pkg.ml args...]; builds and installs the topkg library in ${SRC_DIR}/<name>.
set -euxo pipefail

NAME="${PKG_NAME#ocaml-}"
T="${SRC_DIR}/_tools"
OCAML_STDLIB="$(ocamlc -where | tr -d '\r')"

if [[ "${target_platform:-}" == win-* ]]; then
  PFX="${LIBRARY_PREFIX:-${PREFIX}/Library}"
  EXE=".exe"
  SEP=";"
  # no conda ocaml-findlib for non-unix: build one privately, never into $PREFIX
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
    mkdir -p "${T}/toplevel"
    cp src/findlib/topfind "${T}/toplevel/topfind"
  popd
  export PATH="${T}/bin:${PATH}"
  TOPFIND_DIR="${T}/toplevel"
  # findlib.conf lexer rejects backslashes
  CONF_PFX="${PFX//\\//}"
  CONF_STDLIB="${OCAML_STDLIB//\\//}"
  FINDLIB_LIB="${T//\\//}/lib"

  # non-unix ocamlbuild _3 bakes a stale libdir; recreate it
  OCB_BAKED="$(ocamlbuild -where | tr -d '\r')"
  if [[ ! -f "${OCB_BAKED}/ocamlbuild.cmo" ]]; then
    OCB_DIR="$(cygpath -u "${OCB_BAKED}")"
    mkdir -p "${OCB_DIR}"
    cp -r "${BUILD_PREFIX}/Library/lib/ocaml/ocamlbuild/." "${OCB_DIR}/"
  fi
else
  PFX="${PREFIX}"
  EXE=""
  SEP=":"
  TOPFIND_DIR="${OCAML_STDLIB}"
  CONF_PFX="${PFX}"
  CONF_STDLIB="${OCAML_STDLIB}"
  FINDLIB_LIB="${OCAML_STDLIB}/site-lib"
fi

# ocamlfind runs from the build env but must resolve and install into the host tree
mkdir -p "${T}/etc"
cat > "${T}/etc/findlib.conf" <<EOF
destdir="${CONF_PFX}/lib/ocaml"
path="${CONF_PFX}/lib/ocaml${SEP}${FINDLIB_LIB}${SEP}${CONF_STDLIB}"
EOF
export OCAMLFIND_CONF="${T}/etc/findlib.conf"

cd "${SRC_DIR}/${NAME}"

# pkg.ml does `#use "topfind"`, which only searches cwd, -I dirs and the stdlib dir
ocaml -I "${TOPFIND_DIR}" pkg/pkg.ml build --dev-pkg false "$@"

# opam-free install of <name>.install; doc/man/share/etc entries are not packaged
python - "${NAME}.install" "${PFX}" "${EXE}" <<'EOF'
import os, re, shutil, sys

inst, prefix, exe = sys.argv[1:4]
name = os.path.basename(inst)[: -len(".install")]
libdir = os.path.join(prefix, "lib", "ocaml")
dirs = {
    "lib": os.path.join(libdir, name),
    "lib_root": libdir,
    "stublibs": os.path.join(libdir, "stublibs"),
    "bin": os.path.join(prefix, "bin"),
}
text = open(inst).read()
for sec, body in re.findall(r"^(\w+):\s*\[(.*?)\]", text, re.S | re.M):
    if sec not in dirs:
        continue
    for src, dst in re.findall(r'"([^"]*)"(?:\s*\{\s*"([^"]*)"\s*\})?', body):
        optional = src.startswith("?")
        src = src.lstrip("?")
        out_name = dst or os.path.basename(src)
        if sec == "bin" and exe and not os.path.exists(src) and os.path.exists(src + exe):
            src += exe
        if not os.path.exists(src):
            if optional:
                continue
            sys.exit("%s: missing %s (%s)" % (inst, src, sec))
        if sec == "bin" and src.endswith(exe) and not out_name.endswith(exe):
            out_name += exe
        out = os.path.join(dirs[sec], out_name)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        shutil.copy2(src, out)
EOF
