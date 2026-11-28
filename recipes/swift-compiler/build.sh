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
toolchain_root="${PREFIX}/libexec/swift/usr"
mkdir -p "${toolchain_root}"
if [[ "${target_platform}" == linux-* ]]; then
  # The shared runtime libraries are packaged by swift-runtime, which is
  # already installed in PREFIX.
  #
  # LLDB (and with it the REPL) links the system Python 3.9 of the upstream
  # build host, which conda-forge cannot provide.
  tar -C "${toolchain_usr}" -cf - \
    --exclude='./lib/swift/linux/*.so' \
    --exclude='./bin/lldb*' \
    --exclude='./bin/repl_swift' \
    --exclude='./lib/liblldb*' \
    --exclude='./lib64' \
    . | tar -C "${toolchain_root}" -xf -
else
  cp -R "${toolchain_usr}/." "${toolchain_root}/"
  find "${toolchain_root}" -name '._*' -delete

  # The upstream toolchain is universal. Thin the host tools and libraries to
  # the target architecture; each slice keeps its own code signature. Target
  # libraries (lib/swift/<platform>, lib/swift_static, lib/clang, ...) stay
  # as they are so that building for other architectures keeps working.
  case "${target_platform}" in
    osx-arm64) host_arch=arm64 ;;
    *) host_arch=x86_64 ;;
  esac
  while IFS= read -r -d '' file; do
    if archs="$(lipo -archs "${file}" 2>/dev/null)" && [[ "${archs}" == *" "* ]]; then
      lipo -thin "${host_arch}" "${file}" -output "${file}.thin"
      # Rewrite in place to keep the file mode.
      cat "${file}.thin" > "${file}"
      rm "${file}.thin"
    fi
  done < <(find "${toolchain_root}/bin" "${toolchain_root}"/lib/*.dylib \
    "${toolchain_root}"/lib/*.framework "${toolchain_root}/lib/swift/host" \
    "${toolchain_root}/lib/swift/pm" -type f -print0)
fi

# Expose only Swift-facing tools. Launchers invoke the private paths directly,
# keeping the complete upstream bin/lib/share layout intact for resource lookup.
mkdir -p "${PREFIX}/bin"
for swift_tool in \
  sourcekit-lsp swift swift-api-digester swift-autolink-extract swift-build \
  swift-build-tool swift-demangle swift-experimental-sdk swift-format \
  swift-package swift-package-collection swift-package-registry swift-plugin-server \
  swift-run swift-sdk swift-symbolgraph-extract swift-test swiftc; do
  if [[ -e "${toolchain_root}/bin/${swift_tool}" ]]; then
    cp "${RECIPE_DIR}/swift-wrapper.sh" "${PREFIX}/bin/${swift_tool}"
    chmod +x "${PREFIX}/bin/${swift_tool}"
  fi
done

# Route SwiftPM's compiler invocations through the wrapper as well, keeping the
# real driver reachable under the basename "swiftc".
if [[ "${target_platform}" == linux-* ]]; then
  mkdir -p "${PREFIX}/libexec/swift/driver"
  ln -s ../usr/bin/swift-driver "${PREFIX}/libexec/swift/driver/swiftc"
  rm "${toolchain_root}/bin/swiftc"
  cp "${RECIPE_DIR}/swift-wrapper.sh" "${toolchain_root}/bin/swiftc"
  chmod +x "${toolchain_root}/bin/swiftc"
fi
