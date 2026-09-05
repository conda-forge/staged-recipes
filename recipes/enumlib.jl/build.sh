#!/bin/bash
set -euxo pipefail

# Build the standalone enum.x / polya.x / makestr.x from source.
#
# This is *not* a repackaged release artifact: conda-forge asked for the
# application to be compiled in the recipe (staged-recipes#34550), so we run the
# same PackageCompiler entry point the upstream release workflow runs
# (build/build_app.jl) against conda-forge's own `julia`.
#
# create_app resolves the Julia General registry and downloads binary artifacts,
# which needs network access at build time. That was explicitly sanctioned in the
# review rather than being an oversight here.
#
# Layout in $PREFIX:
#   libexec/enumlib.jl/{bin,lib,share}   <- the compiled application
#   bin/{enum,polya,makestr}.x           <- thin launchers on PATH
#
# Note the application is NOT self-contained the way this project's GitHub release
# tarballs are. conda-forge's julia strips Julia's vendored libraries and links
# against conda-forge's openblas/gmp/mpfr/libgit2/curl, so what we build inherits
# those as runtime dependencies -- which is the point of building here rather than
# shipping a bundle. Binary relocation is therefore left ON (the default): the
# copied runtime carries $PREFIX references that conda-build has to rewrite.

# julia is a host dependency, so call it by path rather than relying on PATH.
JULIA="${PREFIX}/bin/julia"
test -x "${JULIA}"

# Keep the depot inside the build tree: it is a build artifact, must not leak into
# $PREFIX, and must not touch a shared ~/.julia on the builder.
export JULIA_DEPOT_PATH="${SRC_DIR}/.julia-depot"
mkdir -p "${JULIA_DEPOT_PATH}"

# PackageCompiler shells out to a C compiler to link the app's launchers; point it
# at the one conda-forge activated rather than whatever `cc` happens to be first
# on PATH. The value is shell-split (PackageCompiler.get_compiler_cmd), so it can
# carry flags -- if the link step turns out to need ${LDFLAGS} for -L$PREFIX/lib,
# append it here. Starting without, so the first CI build tells us rather than us
# guessing.
export JULIA_CC="${CC}"

# Without this, create_app inherits PackageCompiler's default of "generic", which
# disables vectorized codegen -- a measurable loss for a package that is one hot
# combinatorial loop. This is Julia's own multi-versioning string for x86-64: a
# generic baseline plus sandybridge and haswell clones, selected at load time, so
# the binary still runs on any x86-64.
#
# PROVISIONAL. conda-forge's own convention for this is separate packages per
# x86_64-microarch-level rather than one multi-versioned binary; which way to go
# is an open question on the PR, and the deciding factor is likely system-image
# size, since that already dominates this package.
export JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"

APPDIR="${PREFIX}/libexec/enumlib.jl"
# create_app writes APPDIR itself (and clears it when it already exists), so make
# only its parent.
mkdir -p "${PREFIX}/libexec" "${PREFIX}/bin"

"${JULIA}" --project=build -e 'using Pkg; Pkg.instantiate()'
"${JULIA}" --project=build build/build_app.jl "${APPDIR}"

# create_app emits `enum` / `polya` / `makestr`; the Fortran enumlib these replace
# -- and pymatgen's EnumlibAdaptor, which looks them up on PATH -- use the .x
# names. Renaming inside libexec keeps the launchers below a plain exec.
mv "${APPDIR}/bin/enum"    "${APPDIR}/bin/enum.x"
mv "${APPDIR}/bin/polya"   "${APPDIR}/bin/polya.x"
mv "${APPDIR}/bin/makestr" "${APPDIR}/bin/makestr.x"

for exe in enum.x polya.x makestr.x; do
  test -x "${APPDIR}/bin/${exe}"
  cat > "${PREFIX}/bin/${exe}" <<EOF
#!/bin/bash
# exec preserves argv and the exit status, both of which callers rely on:
# pymatgen's EnumlibAdaptor checks the exit code and passes the input filename
# as a positional argument.
exec "\${CONDA_PREFIX:-${PREFIX}}/libexec/enumlib.jl/bin/${exe}" "\$@"
EOF
  chmod +x "${PREFIX}/bin/${exe}"
done
