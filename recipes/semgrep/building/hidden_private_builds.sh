# HIDDEN(#35158): sourced by build_semgrep_core.sh; needs T, tf, src and OCAMLPATH.
# Private builds into ${T}/lib until conda-forge/staged-recipes#35158 publishes them; later calls see earlier ones via OCAMLPATH.

# hidden_dune <dir under nondune> <opam-pkg[,pkg...]> [pre-step command...]
# -p implies --release, which implies --root . (the pushd dir is the root).
hidden_dune() {
  local dir="$1" pkgs="$2"
  shift 2
  pushd "${src}/nondune/${dir}"
    if [[ $# -gt 0 ]]; then "$@"; fi
    dune build -p "${pkgs}" --profile=release -j "${CPU_COUNT:-2}" @install
    dune install -p "${pkgs}" --prefix="${tf}" --libdir="${tf}/lib" \
      --docdir="${tf}/share/doc" --mandir="${tf}/share/man"
  popd
  test -f "${T}/lib/${pkgs%%,*}/META"
}

# hidden_topkg <dir under nondune> [pkg.ml args...]; installs <dir>.install itself (opam's git dep breaks pkg-config on non-unix)
hidden_topkg() {
  local dir="$1"
  shift
  pushd "${src}/nondune/${dir}"
    ocaml -I "${T}/toplevel" pkg/pkg.ml build --dev-pkg false "$@"
    python - "${dir}.install" "${tf}" <<'EOF'
import os, re, shutil, sys
inst, dest = sys.argv[1], sys.argv[2]
pkg = os.path.basename(inst)[:-len(".install")]
text = open(inst).read()
dirs = {
    "lib": os.path.join(dest, "lib", pkg),
    "lib_root": os.path.join(dest, "lib"),
    "stublibs": os.path.join(dest, "lib", "stublibs"),
    "bin": os.path.join(dest, "bin"),
    "doc": os.path.join(dest, "share", "doc", pkg),
    "share": os.path.join(dest, "share", pkg),
    "man": os.path.join(dest, "share", "man"),
    "etc": os.path.join(dest, "share", pkg, "etc"),
}
for sec, body in re.findall(r"^(\w+):\s*\[(.*?)\]", text, re.S | re.M):
    if sec not in dirs:
        continue
    for src, dst in re.findall(r'"([^"]*)"(?:\s*\{\s*"([^"]*)"\s*\})?', body):
        optional = src.startswith("?")
        src = src.lstrip("?")
        if not os.path.exists(src):
            if optional:
                continue
            sys.exit("%s: missing %s (%s)" % (inst, src, sec))
        out = os.path.join(dirs[sec], dst or os.path.basename(src))
        os.makedirs(os.path.dirname(out), exist_ok=True)
        shutil.copy2(src, out)
EOF
  popd
  test -f "${T}/lib/${dir}/META"
}

# opam runs lwt's discover step first (libev disabled), inside the lwt dir.
hidden_lwt_discover() {
  dune exec -p lwt src/unix/config/discover.exe -- --save --use-libev false
}

hidden_dune ppxlib ppxlib
hidden_dune dune-configurator dune-configurator
hidden_dune ocplib-endian ocplib-endian
hidden_dune lwt lwt hidden_lwt_discover
hidden_dune lwt lwt_ppx
# logs with lwt shadows host ocaml-logs (built without lwt, which ocaml-bos needs).
hidden_topkg logs --with-js_of_ocaml-compiler false --with-fmt true --with-cmdliner true --with-lwt true --with-base-threads true
