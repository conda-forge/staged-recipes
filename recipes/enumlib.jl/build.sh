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
# conda-forge's julia does not ship Julia's bundled share/julia/cert.pem -- conda
# supplies ca-certificates instead. NetworkOptions resolves CA roots as
# JULIA_SSL_CA_ROOTS_PATH, then SSL_CERT_DIR, then SSL_CERT_FILE, then a list of
# well-known /etc paths, and only then Julia's bundled file. None of those /etc
# paths exist in conda-forge's build image, so create_app fell through to the
# bundled path and died on
#
#   IOError: open("$PREFIX/bin/../share/julia/cert.pem", 0, 0): ENOENT
#
# when the Pkg operations inside create_app needed TLS. Point it at conda's bundle
# instead of fabricating the file Julia expects.
#
# The built application never does network I/O -- enum.x, polya.x and makestr.x
# only read and write local files -- so this is a build-time need only, and the
# package deliberately carries no runtime CA dependency.
CONDA_CA_BUNDLE="${PREFIX}/ssl/cacert.pem"
test -f "${CONDA_CA_BUNDLE}"   # from ca-certificates; fail loudly if it moves
export JULIA_SSL_CA_ROOTS_PATH="${CONDA_CA_BUNDLE}"


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

# --- Sharing conda's libraries instead of bundling copies (staged-recipes#34550)
#
# conda-forge's julia deliberately symlinks lib/julia/* out to $PREFIX/lib, so Julia
# uses conda's openblas/gmp/mpfr/suitesparse rather than its own vendored copies.
# create_app recreates those links verbatim inside the application -- Julia's `cp`
# defaults to follow_symlinks=false -- where `../` resolves inside the app tree and
# the links dangle; a later pass retries the same destination and symlink() throws
# EEXIST, which is what ended the osx-64 build.
#
# So: materialise the links into real files for the duration of create_app (Julia
# keeps working, PackageCompiler copies files, nothing throws), then point the
# application's copies at $PREFIX/lib and restore the host links. The application
# ends up sharing conda's libraries rather than duplicating ~74 MB of them, 66 MB
# of which is OpenBLAS alone.
JULIA_LIBDIR="${PREFIX}/lib/julia"
LINK_MANIFEST="${SRC_DIR}/julia-lib-symlinks.tsv"
: > "${LINK_MANIFEST}"

if [ -d "${JULIA_LIBDIR}" ]; then
  while IFS= read -r link; do
    name="$(basename "${link}")"
    target="$(readlink "${link}")"
    resolved="$(cd "$(dirname "${link}")" && cd "$(dirname "${target}")" && pwd)/$(basename "${target}")"
    # Links that stay inside lib/julia resolve fine in the app; leave them be.
    case "${resolved}" in
      "${JULIA_LIBDIR}"/*) continue ;;
    esac
    if [ ! -e "${resolved}" ]; then
      echo "warning: ${link} -> ${target} is already dangling in the host env; skipping"
      continue
    fi
    printf '%s\t%s\n' "${name}" "${target}" >> "${LINK_MANIFEST}"
    rm "${link}"
    cp "${resolved}" "${link}"
  done < <(find "${JULIA_LIBDIR}" -maxdepth 1 -type l)
fi
echo "materialised $(wc -l < "${LINK_MANIFEST}" | tr -d ' ') host symlink(s) for the build"

"${JULIA}" --project=build -e 'using Pkg; Pkg.instantiate()'
"${JULIA}" --project=build build/build_app.jl "${APPDIR}"

# Point the application's copied libraries back at conda's, and put the host env
# back the way conda-forge's julia package had it.
APP_LIBJULIA="${APPDIR}/lib/julia"
# $APPDIR is $PREFIX/libexec/enumlib.jl, so lib/julia sits four levels below
# $PREFIX. Relative rather than absolute deliberately: the link never leaves
# $PREFIX, so there is nothing for conda's prefix rewriting to fix up.
REL_TO_PREFIX_LIB="../../../../lib"

while IFS="$(printf '\t')" read -r name target; do
  [ -n "${name}" ] || continue
  # Prefer the unversioned soname where conda ships one, so an ABI-compatible
  # rebuild of openblas does not strand the link on a versioned filename.
  if [ -e "${PREFIX}/lib/${name}" ]; then
    conda_name="${name}"
  else
    conda_name="$(basename "${target}")"
  fi
  rm -f "${APP_LIBJULIA}/${name}"
  ln -s "${REL_TO_PREFIX_LIB}/${conda_name}" "${APP_LIBJULIA}/${name}"
  # Fail the build rather than ship a dangling link if the layout ever moves.
  test -e "${APP_LIBJULIA}/${name}"
  rm -f "${JULIA_LIBDIR}/${name}"
  ln -s "${target}" "${JULIA_LIBDIR}/${name}"
done < "${LINK_MANIFEST}"
echo "repointed $(wc -l < "${LINK_MANIFEST}" | tr -d ' ') application librar(y|ies) at ${PREFIX}/lib"

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
