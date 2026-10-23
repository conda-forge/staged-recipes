#!/usr/bin/env bash
set -euxo pipefail

export NIMBLE_DIR="${SRC_DIR}/.nimble"
mkdir -p "${NIMBLE_DIR}" "${PREFIX}/bin"

# Build the local package (fetches cligen/checksums into NIMBLE_DIR).
nimble build -y --nimbleDir:"${NIMBLE_DIR}"

# Nim compiles to C and links its dependencies into the executable, so
# the binary carries their code and their licences ship beside our own.
#
# The licences come from nimble's download cache rather than from the
# installed package directories: an install copies srcDir and the
# extensions a package declares, so pkgs2/<dep>/ holds the code without
# its LICENSE while pkgcache/<dep>/ holds the repository as fetched.
license_dir="${SRC_DIR}/third-party-licenses"
mkdir -p "${license_dir}"
shopt -s nullglob

for pkg_dir in "${NIMBLE_DIR}"/pkgs2/*/; do
  # pkgs2 entries are <name>-<version>-<hash>; cache entries are keyed by
  # origin and version. Match on both: nimble keeps every version it has
  # fetched and only the installed one is linked in.
  pkg="$(basename "${pkg_dir}")"
  name="${pkg%%-*}"
  rest="${pkg#*-}"
  version="${rest%%-*}"

  found=""
  for cache_dir in "${NIMBLE_DIR}"/pkgcache/*"${name}"*_"${version}"/; do
    for candidate in LICENSE LICENSE.md LICENSE.txt COPYING COPYING.txt license.txt; do
      if [ -f "${cache_dir}${candidate}" ]; then
        cp "${cache_dir}${candidate}" "${license_dir}/${name}-${version}.${candidate}"
        found="yes"
        break
      fi
    done
    [ -n "${found}" ] && break
  done

  if [ -z "${found}" ]; then
    echo "no licence file found for nimble dependency ${name} ${version}" >&2
    exit 1
  fi
done

ls -1 "${license_dir}"

install -m 755 bin/nimvault "${PREFIX}/bin/nimvault"
test -x "${PREFIX}/bin/nimvault"
