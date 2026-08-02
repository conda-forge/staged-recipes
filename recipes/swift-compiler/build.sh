#!/usr/bin/env bash
set -euxo pipefail

# target_platform is supplied by rattler-build.
# shellcheck disable=SC2154
if [[ "${target_platform}" == osx-* ]]; then
  # Expand the signed Apple installer without running its installation scripts.
  pkgutil --expand-full "${SRC_DIR}/swift.pkg" expanded
  payload="expanded/swift-${PKG_VERSION}-RELEASE-osx-package.pkg/Payload"
  toolchain_usr="${payload}/usr"
else
  # rattler-build strips the single top-level directory from Linux archives.
  toolchain_usr="${SRC_DIR}/usr"
fi

# Flatten the upstream toolchain's usr directory into the conda prefix while
# preserving the relative bin/lib/share layout used by the compiler.
cp -R "${toolchain_usr}/." "${PREFIX}/"
find "${PREFIX}" -name '._*' -delete

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/activate.sh" \
  "${PREFIX}/etc/conda/activate.d/activate-swift.sh"
cp "${RECIPE_DIR}/deactivate.sh" \
  "${PREFIX}/etc/conda/deactivate.d/deactivate-swift.sh"
