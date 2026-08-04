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

# Keep Swift's version-coupled LLVM/Clang toolchain private. Flattening it into
# PREFIX would collide with conda-forge's clang, lld, and lldb packages.
toolchain_root="${PREFIX}/libexec/swift"
mkdir -p "${toolchain_root}"
cp -R "${toolchain_usr}/." "${toolchain_root}/"
find "${toolchain_root}" -name '._*' -delete

# Expose only Swift-facing tools. Launchers invoke the private paths directly,
# keeping the complete upstream bin/lib/share layout intact for resource lookup.
mkdir -p "${PREFIX}/bin"
for swift_tool in \
  sourcekit-lsp swift swift-api-digester swift-autolink-extract swift-build \
  swift-build-tool swift-demangle swift-experimental-sdk swift-format \
  swift-package swift-package-collection swift-package-registry swift-plugin-server \
  swift-run swift-sdk swift-symbolgraph-extract swift-test; do
  if [[ -e "${toolchain_root}/bin/${swift_tool}" ]]; then
    cp "${RECIPE_DIR}/swift-wrapper.sh" "${PREFIX}/bin/${swift_tool}"
    chmod +x "${PREFIX}/bin/${swift_tool}"
  fi
done

# The upstream Linux driver does not know where conda-forge installs its
# sysroot and GCC runtime. This public launcher supplies those paths, and
# SwiftPM also uses it through SWIFT_EXEC.
if [[ "${target_platform}" == linux-* ]]; then
  cp "${RECIPE_DIR}/swiftc-wrapper.sh" "${PREFIX}/bin/swiftc"
  chmod +x "${PREFIX}/bin/swiftc"
else
  cp "${RECIPE_DIR}/swift-wrapper.sh" "${PREFIX}/bin/swiftc"
  chmod +x "${PREFIX}/bin/swiftc"
fi

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/activate.sh" \
  "${PREFIX}/etc/conda/activate.d/zz-activate-swift.sh"
cp "${RECIPE_DIR}/deactivate.sh" \
  "${PREFIX}/etc/conda/deactivate.d/zz-deactivate-swift.sh"
