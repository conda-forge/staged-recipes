#!/usr/bin/env bash
set -euxo pipefail

# Keep gdb curses/termcap-free (stub termcap, no TUI). Conda build tools drag
# ncurses into the build environment transitively, but any conda .so in the
# host binaries' NEEDED entries could not be resolved at runtime (binary prefix
# relocation is off, so baked rpaths are dead). Preset the configure caches so
# gdb behaves as on a system without curses.
export ac_cv_search_tgetent=no ac_cv_search_waddstr=no \
       ac_cv_header_curses_h=no ac_cv_header_ncurses_h=no \
       ac_cv_header_ncurses_ncurses_h=no ac_cv_header_ncurses_curses_h=no

if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS links the system libc++/libSystem, which is always present -- no
  # static-linking flags needed for host portability. (Docs are built with
  # conda's texinfo on every platform; a MAKEINFO=true stub does not work,
  # because configure probes `$MAKEINFO --version` and substitutes the
  # `missing` script for anything that fails it.)

  # The prerequisite libraries in Arm's snapshot bundle 2018-era
  # config.sub/config.guess that predate the arm64-apple triple, so mpfr's
  # configure aborts with "config.sub arm64-apple-darwin20.0.0 failed".
  # Refresh every copy from conda's gnuconfig. rm first: some trees ship
  # them read-only, and cp alone would fail on the second run.
  find src -name config.sub -o -name config.guess | while read -r f; do
    rm -f "$f"
    cp "${BUILD_PREFIX}/share/gnuconfig/$(basename "$f")" "$f"
  done

  # The zlib bundled with the binutils and gcc trees #defines fdopen to NULL
  # on macOS (a pre-OS-X workaround, removed in later upstream zlib), which
  # breaks the fdopen declaration in the modern SDK's _stdio.h ("expected
  # ')'"). Drop it, as the gap-riscv-gnu-toolchain recipe does.
  find src -path '*/zlib/zutil.h' -exec sed -i '/define fdopen(fd,mode) NULL/d' {} +

  # bison regenerates binutils' windres grammars (defparse.y, rcparse.y) and
  # searches for its m4 by the name "gm4" first, which on the runner resolves
  # to Xcode's BSD gm4 ("unrecognized option --gnu", SIGPIPE, Error 141).
  # Pin it to conda's GNU m4 explicitly; bison honours $M4 over any search.
  export M4="${BUILD_PREFIX}/bin/m4"

  # libtool's nm search settles on "nm -B", but its symbol-parse probe then
  # fails on that output ("checking command to parse ... nm -B output ...
  # failed" in the log, versus "... nm output ... ok" without the flag),
  # leaving an empty global_symbol_pipe. lto-plugin's libtool then emits a
  # pipeline with a blank stage ("nm -B ... | | sed ...") and dies with a
  # syntax error at liblto_plugin.la. Preset the search's cache variable to
  # conda's nm without -B; the probe is proven to parse that.
  export lt_cv_path_NM="${NM:-nm}"
else
  # Host tools must depend on glibc only. Append to the conda activation's
  # LDFLAGS rather than replacing them.
  export LDFLAGS="${LDFLAGS:-} -static-libstdc++ -static-libgcc"
fi

# The conda compiler activation exports CPP pointing at the *host*
# preprocessor. GCC's BASE_TARGET_EXPORTS (which target libraries such as
# libgcc and newlib are configured under) sets CC/CFLAGS/CPPFLAGS for the
# target but never CPP, so the ambient host value reaches their
# AC_CHECK_HEADERS probes: libgcc's configure concluded bare-metal
# arm-none-eabi has sys/mman.h and libgcov.h then failed to compile.
# CC/CXX are left alone -- the host tools genuinely need the conda compiler,
# and host configures derive their preprocessor from $CC -E.
#
# This unset is only effective on a CLEAN build: autoconf records precious
# variables like CPP into ac_configure_args (visible in each config.status),
# and configure re-runs on an existing tree replay that recorded value no
# matter what the environment says. Passing ac_cv_header_sys_mman_h=no via
# --config-flags-gcc does not work either: the top-level GCC configure
# accepts VAR=VALUE arguments but does not forward them to the target-library
# sub-configures.
unset CPP CPP_FOR_BUILD

# The build scripts stage gmp/mpfr/mpc/isl/zstd into $builddir/host-tools and
# link them statically. Arm's scripts never constrain pkg-config, so on a
# machine that has development packages installed, a component can silently
# resolve a system library instead: binutils detects zstd *only* via
# pkg-config (its configure gets no --with-zstd from these scripts), found
# /usr/lib64/pkgconfig/libzstd.pc, and built with ZSTD_LIBS=-lzstd and an empty
# ZSTD_CFLAGS -- which both fails ("zstd.h: No such file or directory") and
# would have linked a system library that is not there at runtime.
#
# PKG_CONFIG_LIBDIR *replaces* the default search path (PKG_CONFIG_PATH only
# prepends to it), so pointing it at an empty directory takes /usr/lib64 out of
# consideration for every component, not just zstd.
export PKG_CONFIG_LIBDIR="${SRC_DIR}/empty-pkgconfig"
mkdir -p "${PKG_CONFIG_LIBDIR}"

# Hand binutils the in-tree zstd directly. Its configure honours these as
# documented overrides ("C compiler flags for ZSTD, overriding pkg-config") and
# skips the pkg-config query entirely when ZSTD_CFLAGS is non-empty. The zstd
# stage installs only headers and the static lib -- it never writes a
# libzstd.pc -- so there is nothing for pkg-config to find in-tree anyway.
builddir="${SRC_DIR}/build-arm-none-eabi"
export ZSTD_CFLAGS="-I${builddir}/host-tools/include"
export ZSTD_LIBS="-L${builddir}/host-tools/lib -lzstd"

# Build the target libraries without debug info. The packaged libraries are
# stripped of their heavy .debug_* sections at the end of this script anyway,
# so the DWARF is dead weight -- but it is dead weight that has to exist on
# disk first, in both the obj trees and the install tree, and it is roughly
# 60% of every target .a. That peak is what exhausted the CI disk part-way
# through the final per-multilib libstdc++ builds.
#
# build-baremetal-toolchain.sh hardcodes these two variables (it does not read
# them from the environment), so patch them in place. -g becomes -g0 rather
# than being dropped so any later "$cflags_for_target -g"-style concatenation
# in the script still resolves to no debug info. Note this also removes
# .debug_frame, which the strip step deliberately keeps for stack unwinding
# through libc/libstdc++; -fasynchronous-unwind-tables preserves the .ARM.exidx
# unwind tables that bare-metal C++ exception handling actually depends on.
sed -i \
  -e 's|^\(  cflags_for_target="\$cflags_for_target_common -O2\) -g"$|\1 -g0 -fasynchronous-unwind-tables"|' \
  -e 's|^\(  cflags_for_nano_target="\$cflags_for_target_common -Os\) -g"$|\1 -g0 -fasynchronous-unwind-tables"|' \
  "${SRC_DIR}/src/gnu-devtools-for-arm/build-baremetal-toolchain.sh"

# Fail loudly if Arm reshaped those lines in a later devtools revision, rather
# than silently building a multi-hour full-DWARF toolchain again.
grep -q -- '-g0 -fasynchronous-unwind-tables' \
  "${SRC_DIR}/src/gnu-devtools-for-arm/build-baremetal-toolchain.sh"

# Cortex-M only. GCC's arm port accepts just three forms of
# --with-multilib-list: "aprofile", "rmprofile", or "@<fragment>" naming a
# makefile fragment in gcc/config/arm (see the arm case in gcc/config.gcc) --
# there is no "mprofile" value. "rmprofile" pulls in arm/t-multilib, whose own
# body unconditionally adds the legacy ARM and R-profile multilibs (v5te, v7,
# v7+fp, v7-r+fp.sp) on top of the purely M-profile set that arm/t-rmprofile
# contributes; that is 7 of the 28 libraries built.
#
# So drop to a custom fragment that includes t-rmprofile and re-declares only
# the M-profile axes. This mirrors the tail of t-multilib (the marm/mthumb,
# march and mfloat-abi option lists) with the four non-M architectures and
# their MULTILIB_REQUIRED lines removed. mthumb/mfloat-abi=soft is kept: it is
# the default multilib, used when no -mcpu/-march selects a more specific one.
#
# Building this from the environment rather than editing the source in place
# keeps the change auditable and confined to one file.
cat > "${SRC_DIR}/src/gcc/gcc/config/arm/t-mprofile" <<'EOF'
# M-profile only multilibs, derived from arm/t-multilib.
comma := ,
tm_multilib_list := $(subst $(comma), ,$(TM_MULTILIB_CONFIG))

MULTILIB_OPTIONS     =
MULTILIB_DIRNAMES    =
MULTILIB_EXCEPTIONS  =
MULTILIB_MATCHES     =
MULTILIB_REUSE       =
MULTILIB_REQUIRED    =

include $(srcdir)/config/arm/t-rmprofile

MULTILIB_OPTIONS        += marm/mthumb
MULTILIB_DIRNAMES       += arm thumb

MULTILIB_OPTIONS        += $(MULTI_ARCH_OPTS_RM)
MULTILIB_DIRNAMES       += $(MULTI_ARCH_DIRS_RM)

MULTILIB_OPTIONS        += mfloat-abi=soft/mfloat-abi=softfp/mfloat-abi=hard
MULTILIB_DIRNAMES       += nofp softfp hard

# The default multilib, selected when no -mcpu/-march picks a specific one.
MULTILIB_REQUIRED       += mthumb/mfloat-abi=soft
EOF

# build-baremetal-toolchain.sh takes the install location from the environment
# (there is no command-line flag for it) and configures gcc with an absolute
# --prefix="$installdir", so this installs straight into the conda build prefix
# and rattler-build records relocatable placeholders. $prefix must stay "/" so
# files land at $PREFIX/bin rather than $PREFIX/usr/bin.
export installdir="$PREFIX"
export prefix="/"
# newlib-nano is staged separately and then merged into $installdir by the
# script itself (libc.a -> libc_nano.a and friends, plus nano.specs), so this
# must be a scratch path and NOT $PREFIX.
export nano_installdir="${SRC_DIR}/nano_install"

# Call build-baremetal-toolchain.sh directly rather than through the
# build-gnu-toolchain.sh wrapper. The wrapper treats everything after "--" as
# make targets (it `break 2`s out of its option parser), so the "-- --release
# --enable-newlib-nano" form shown in Arm's README would silently pass those as
# build stage names. Going one level down makes the configuration explicit; the
# flags below reproduce what the wrapper generates for --target=arm-none-eabi
# --rmprofile, minus the Fortran frontend.
#
# --release              turns down self-consistency checking, as Arm's own
#                        release builds do
# --no-package           we want the install tree, not distribution tarballs
# --with-multilib-list   @t-mprofile: Cortex-M only, via the custom fragment
#                        written above. rmprofile would add 7 legacy-ARM and
#                        R-profile multilibs on top; aprofile roughly doubles
#                        an already multi-hour build.
# --disable-libcc1       gdb's compile-anything plugin — useless for an
#                        embedded cross toolchain, and a host plugin .so has
#                        no place in a package whose binaries must be
#                        self-contained
# --disable-libstdcxx-pch
#                        Do not precompile <bits/stdc++.h> & friends. libstdc++
#                        builds PCH files (stdc++, stdtr1c++, extc++, plus
#                        per-std-mode variants) at ~100-145 MB each; the failed
#                        run wrote 151 of them across the 21 multilibs, on the
#                        order of 15-20 GB of build tree and by far the largest
#                        consumer of CI disk. They are pure build-time scratch:
#                        the install tree ships no .gch at all, so dropping
#                        them costs nothing at runtime. This is what the
#                        second CI run died on ("cannot write PCH file: No
#                        space left on device"), after -g0 and the multilib cut
#                        had already trimmed the target libraries -- -g0 shrinks
#                        a PCH by only ~12%, so it could not fix this by itself.
# no --tag               Arm asks that their release branding not be reused
"${SRC_DIR}/src/gnu-devtools-for-arm/build-baremetal-toolchain.sh" \
  --target=arm-none-eabi \
  --srcdir="${SRC_DIR}/src" \
  --builddir="${builddir}" \
  -j "${CPU_COUNT}" \
  --release \
  --no-package \
  --enable-newlib-nano \
  --disable-qemu \
  --no-check-gdb \
  --config-flags-gcc=--with-multilib-list=@t-mprofile \
  --config-flags-gcc=--disable-libcc1 \
  --config-flags-gcc=--disable-libstdcxx-pch \
  --bugurl="https://github.com/conda-forge/gcc-arm-none-eabi-feedstock/issues"

# Fail if PCH generation happened anyway: --disable-libstdcxx-pch not taking
# effect is the difference between a build that fits on a CI runner and one
# that does not, and a silent regression there would only surface hours later
# as "No space left on device". Nothing in the install tree should be a .gch.
if find "${builddir}/obj" "$PREFIX" -name '*.gch' -print -quit 2>/dev/null | grep -q .; then
  echo "ERROR: precompiled headers were built despite --disable-libstdcxx-pch" >&2
  exit 1
fi

# Strip any remaining debug sections from the target libraries and objects, as
# Arm's own releases do (utilities.sh strip_lib, run by the perms stage that
# only executes with --package). Since the -g0 patch above, the target
# libraries carry no DWARF to begin with and this mostly removes .comment and
# .note -- it is kept because the prerequisite libraries and any object not
# covered by cflags_for_target can still arrive with debug sections, and
# because it is what bounds the package size if that patch ever stops
# applying. Uses the freshly built cross objcopy from the install itself.
OBJCOPY="$PREFIX/bin/arm-none-eabi-objcopy"
find "$PREFIX" \( -name '*.a' -o -name '*.o' \) -print0 | while IFS= read -r -d '' f; do
  "$OBJCOPY" -R .comment -R .note -R .debug_info -R .debug_aranges \
    -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line \
    -R .debug_str -R .debug_ranges -R .debug_loc -R .debug_rnglists \
    -R .debug_loclists "$f" || true
done

# The obj trees, staged host tools and nano staging area total ~20 GB and are
# dead weight once the toolchain is installed into $PREFIX -- but they are
# still on disk while rattler-build packages the 2.7 GB install, and the
# osx-arm64 runner ran out of space exactly there ("Could not open or create,
# or write to file: No space left on device" during packaging, after a fully
# successful build). Drop them first.
rm -rf "${builddir}/obj" "${builddir}/host-tools" "${SRC_DIR}/nano_install"

# Strip host binaries before packaging. Target libraries (newlib .a) must keep
# their symbols — only bin/ and libexec/. STRIP is the conda binutils' host
# strip from the compiler activation.
find "$PREFIX"/bin "$PREFIX"/libexec -type f | xargs -r "${STRIP:-strip}" -- 2>/dev/null || true
find "$PREFIX" -name '*.la' -delete

# The release build generates the full texinfo/man documentation set; drop it
# to keep the package a sane size.
rm -rf "$PREFIX"/share/info "$PREFIX"/share/doc "$PREFIX"/share/man
