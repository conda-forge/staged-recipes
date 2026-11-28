#!/usr/bin/env bash
# Native pdfium build with conda-forge compilers and system libraries.
# Adapted from pypdfium2's setupsrc/build_native.py (Apache-2.0 OR BSD-3-Clause).
set -euxo pipefail

# --- Source patches (see pypdfium2 shared_autopatches / bin_autopatch) ---
# Make public C++ headers usable from an installed include dir.
sed -i -E 's|"public/(.+)"|"../\1"|' public/cpp/*.h
# Export the public API symbols.
sed -i 's|#if defined(COMPONENT_BUILD)|#if 1  // defined(COMPONENT_BUILD)|' public/fpdfview.h
# Build a single shared library that bundles internal deps (abseil, ...).
sed -i 's|component("pdfium")|shared_library("pdfium")|' BUILD.gn
# Use the python from the build environment.
sed -i -E "s|(script_executable) = \"(.+)\"|\1 = \"${BUILD_PREFIX}/bin/python\"|" .gn
# fxcodec depends on the bundled lcms2 directly, bypassing the
# //third_party:lcms2 group that honours use_system_lcms2.
sed -i 's|"../../third_party:fx_lcms2",|"../../third_party:lcms2",|' core/fxcodec/BUILD.gn
grep -q '"../../third_party:lcms2"' core/fxcodec/BUILD.gn
# test_fonts are not checked out.
sed -i -E 's|^(\s*)("//third_party/test_fonts")|\1# \2|' testing/BUILD.gn

# Pseudo gclient config included by //build.
cat > build/config/gclient_args.gni <<GNI
build_with_chromium = false
checkout_libpng = true
GNI

# fxcodec always wants libjpeg_turbo's header target; with system libjpeg the
# headers come from $PREFIX/include, so an empty stub is enough.
mkdir -p third_party/libjpeg_turbo
cat > third_party/libjpeg_turbo/BUILD.gn <<GNI
group("libjpeg_headers") {
}
GNI

# Unbundle ICU.
mkdir -p third_party/icu
cp build/linux/unbundle/icu.gn third_party/icu/BUILD.gn

case "${target_platform}" in
  linux-64)      TARGET_CPU=x64 ;;
  linux-aarch64) TARGET_CPU=arm64 ;;
  linux-ppc64le) TARGET_CPU=ppc64 ;;
  *) echo "Unsupported platform ${target_platform}"; exit 1 ;;
esac

# Custom GCC toolchain using conda-forge's compilers and flags.
# -ffp-contract=off: https://crbug.com/402282789
export CPPFLAGS="${CPPFLAGS:-} -ffp-contract=off"
mkdir -p build/toolchain/linux/conda
cat > build/toolchain/linux/conda/BUILD.gn <<GNI
import("//build/toolchain/gcc_toolchain.gni")

gcc_toolchain("default") {
  cc = "${CC}"
  cxx = "${CXX}"
  ld = cxx
  ar = "${AR}"
  nm = "${NM}"
  readelf = "${READELF}"

  extra_cflags = getenv("CFLAGS")
  extra_cppflags = getenv("CPPFLAGS")
  extra_cxxflags = getenv("CXXFLAGS")
  extra_ldflags = getenv("LDFLAGS")

  toolchain_args = {
    current_cpu = "${TARGET_CPU}"
    current_os = "linux"
  }
}
GNI

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

mkdir -p out/Release
cat > out/Release/args.gn <<GNI
is_debug = false
target_os = "linux"
target_cpu = "${TARGET_CPU}"
is_clang = false
custom_toolchain = "//build/toolchain/linux/conda:default"
host_toolchain = "//build/toolchain/linux/conda:default"
use_sysroot = false
use_glib = false
use_siso = false
use_custom_libcxx = false
use_cxx23 = false
treat_warnings_as_errors = false
clang_use_chrome_plugins = false
is_component_build = false
pdf_is_standalone = true
pdf_enable_v8 = false
pdf_enable_xfa = false
pdf_enable_brotli = false
pdf_use_skia = false
pdf_use_libyuv = false
pdf_use_partition_alloc = false
pdf_bundle_freetype = false
use_system_freetype = true
use_system_harfbuzz = true
use_system_lcms2 = true
use_system_libjpeg = true
use_system_libopenjpeg2 = true
use_system_libpng = true
use_system_libtiff = true
use_system_zlib = true
GNI

gn gen out/Release
ninja -C out/Release -j "${CPU_COUNT}" pdfium

# --- Install ---
install -Dm755 out/Release/libpdfium.so "${PREFIX}/lib/libpdfium.so"
mkdir -p "${PREFIX}/include/pdfium"
cp -r public/*.h public/cpp "${PREFIX}/include/pdfium/"

mkdir -p "${PREFIX}/lib/pkgconfig"
cat > "${PREFIX}/lib/pkgconfig/libpdfium.pc" <<PC
prefix=${PREFIX}
libdir=\${prefix}/lib
includedir=\${prefix}/include/pdfium

Name: libpdfium
Description: PDF rendering and manipulation library from the Chromium project
Version: ${PKG_VERSION}
Libs: -L\${libdir} -lpdfium
Cflags: -I\${includedir}
PC
