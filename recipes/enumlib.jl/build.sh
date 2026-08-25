#!/bin/bash
set -euxo pipefail

# The source is a PackageCompiler application: bin/ holds enum.x, polya.x and
# makestr.x, lib/ holds the bundled Julia runtime and its shared libraries. The
# executables locate their libraries via RPATH relative to their own path
# (@executable_path/../lib, $ORIGIN/../lib), so the tree must be installed intact
# and not relocated piecemeal.
#
# Layout in $PREFIX:
#   libexec/enumlib.jl/{bin,lib,share}   <- the application, unmodified
#   bin/{enum,polya,makestr}.x           <- thin launchers on PATH

APPDIR="${PREFIX}/libexec/enumlib.jl"
mkdir -p "${APPDIR}" "${PREFIX}/bin"

# Tolerate either extraction layout: the archive has a single top-level
# directory, which some extractors strip and others keep.
SRC="."
CANDIDATE="$(ls -d enumlib-jl-* 2>/dev/null | head -n 1 || true)"
if [ -n "${CANDIDATE:-}" ] && [ -d "${CANDIDATE}" ]; then
  SRC="${CANDIDATE}"
fi
cp -R "${SRC}/." "${APPDIR}/"

test -x "${APPDIR}/bin/enum.x"
test -x "${APPDIR}/bin/polya.x"
test -x "${APPDIR}/bin/makestr.x"

for exe in enum.x polya.x makestr.x; do
  cat > "${PREFIX}/bin/${exe}" <<EOF
#!/bin/bash
# exec preserves argv and the exit status, both of which callers rely on:
# pymatgen's EnumlibAdaptor checks the exit code and passes the input filename
# as a positional argument.
exec "\${CONDA_PREFIX:-${PREFIX}}/libexec/enumlib.jl/bin/${exe}" "\$@"
EOF
  chmod +x "${PREFIX}/bin/${exe}"
done
