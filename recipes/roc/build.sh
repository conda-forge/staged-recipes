#!/usr/bin/env bash
# Run by brush (see build.script.interpreter), which is bash-compatible and is
# invoked with -euxo pipefail already, so no `set` prologue is needed here.

# Zig otherwise writes to a global cache under $HOME, which is not writable here.
export ZIG_GLOBAL_CACHE_DIR="${SRC_DIR}/.zig-global-cache"

# Note the requirements: this deliberately does not pull in conda's C/C++
# compilers. Zig ships a complete toolchain and roc uses nothing from GCC, and
# their presence actively breaks the build -- mid-build roc compiles and runs a
# host tool (builtin_compiler) for the *native* target, which -Dtarget does not
# cover. Zig then resolves that one against the conda sysroot's glibc 2.17 while
# targeting the running 2.34, and the two disagree: either an unresolvable
# absolute path in 2.17's `libpthread.so` ld script, or undefined getrandom /
# copy_file_range / statx.
#
# --system resolves every dependency from the pre-populated package directory
# rather than fetching it, which keeps the build offline.
if [[ "${target_platform}" == osx-* ]]; then
  # Both macOS builds link conda-forge's LLVM, but they differ on -Dtarget, which
  # is what fixes LC_BUILD_VERSION. Zig ignores MACOSX_DEPLOYMENT_TARGET, so a
  # build that does not name the version stamps the *builder's* OS version and
  # dyld then refuses to load the result on anything older than the CI runner.
  if [[ "${target_platform}" == "${build_platform}" ]]; then
    # Native. -Dtarget would pin the version but stops Zig auto-detecting the
    # SDK, and CoreFoundation/CoreServices then go missing -- roc links them
    # here because the build is native (linkWatchPlatformLibs in build.zig), and
    # that is also what enables its real FSEvents watcher. So build without it
    # and correct the load command afterwards; everything linked in is built for
    # the deployment target already.
    zig build roc \
      -Doptimize=ReleaseFast \
      -Dllvm-path="${PREFIX}" \
      --system "${SRC_DIR}/zig-pkg" \
      --summary all

    vtool_bin=$(echo "${BUILD_PREFIX}"/bin/*-vtool)
    "${vtool_bin}" -set-build-version macos \
      "${MACOSX_DEPLOYMENT_TARGET}" "${MACOSX_DEPLOYMENT_TARGET}" \
      -replace -output zig-out/bin/roc.retargeted zig-out/bin/roc
    mv zig-out/bin/roc.retargeted zig-out/bin/roc
  else
    # Cross (conda-forge builds osx-64 on an arm64 runner). Losing SDK detection
    # costs nothing here: roc only links the macOS frameworks when target and
    # host architectures match, so a cross build does not ask for them, and Zig
    # supplies its own libSystem stubs. -Dtarget therefore just works and sets
    # the deployment target correctly, so no vtool pass is needed.
    if [[ "${target_platform}" == "osx-64" ]]; then
      zig_arch="x86_64"
    else
      zig_arch="aarch64"
    fi

    zig build roc \
      -Doptimize=ReleaseFast \
      -Dtarget="${zig_arch}-macos.${MACOSX_DEPLOYMENT_TARGET}-none" \
      -Dllvm-path="${PREFIX}" \
      --system "${SRC_DIR}/zig-pkg" \
      --summary all
  fi
else
  # LLVM comes from the vendored roc-bootstrap tarball staged into zig-pkg, so
  # roc's default path picks it up as the lazy dependency it already expects and
  # no -Dllvm-path is needed.
  #
  # Zig does not consult the conda sysroot, so left alone it would link against
  # whatever glibc the runner happens to have (2.34 on the alma9 image) while the
  # package metadata promises the much older one conda-forge targets. Name it
  # explicitly. roc's `target_is_native` check only compares os/arch/abi, so
  # pinning the glibc version here still counts as a native build.
  # if/elif rather than case: brush 0.4.0 exits 1 on a `case` nested in an `else`
  # when xtrace is on, which is how rattler-build invokes it (-euxo pipefail).
  if [[ "${target_platform}" == "linux-64" ]]; then
    zig_target="x86_64-linux-gnu.${c_stdlib_version:-2.17}"
  elif [[ "${target_platform}" == "linux-aarch64" ]]; then
    zig_target="aarch64-linux-gnu.${c_stdlib_version:-2.17}"
  else
    echo "unsupported target_platform: ${target_platform}" >&2
    exit 1
  fi

  zig build roc \
    -Doptimize=ReleaseFast \
    -Dtarget="${zig_target}" \
    --system "${SRC_DIR}/zig-pkg" \
    --summary all
fi

install -d "${PREFIX}/bin"
install -m 755 zig-out/bin/roc "${PREFIX}/bin/roc"

if [[ "${target_platform}" == osx-* ]]; then
  # roc's embedded lld needs a libSystem stub to link the programs it compiles.
  # The path baked in at build time points into the source tree, which is gone by
  # then, but findDarwinSysroot (src/cli/linker.zig) prefers a `darwin` directory
  # next to the executable -- what upstream's own release tarballs ship.
  install -d "${PREFIX}/bin/darwin/usr/lib"
  install -m 644 src/cli/darwin/usr/lib/libSystem.tbd "${PREFIX}/bin/darwin/usr/lib/libSystem.tbd"
fi
