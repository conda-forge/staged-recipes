#!/usr/bin/env bash
set -ex

# Runtime cache directory for compiled XKB keymaps. xkbcomp writes the
# compiled keymap here when the server starts; conda relocates this path to
# the install prefix. Ship it (with a placeholder so the empty dir survives
# packaging) and make sure it exists.
mkdir -p "${PREFIX}/share/X11/xkb/compiled"
touch "${PREFIX}/share/X11/xkb/compiled/.keep"

# GLX is software server-side OpenGL (the DRI1/2/3 extensions are for a real
# GPU/DRM device and are left disabled). With GLX enabled the xserver looks up
# Mesa's `dri.pc` (dependency('dri', required: build_glx)) purely to learn the
# directory baked in as DRI_DRIVER_PATH, where the GLX module searches for a
# software driver (swrast_dri.so) at runtime. conda-forge's Mesa (mesalib) does
# not ship that file, so we provide a minimal stub pointing at ${PREFIX}/lib/dri
# (where a Mesa software DRI driver is made available at runtime). The stub is
# written into the host pkg-config dir so meson resolves it, then removed before
# packaging.
mkdir -p "${PREFIX}/lib/pkgconfig"
cat > "${PREFIX}/lib/pkgconfig/dri.pc" <<EOF
dridriverdir=${PREFIX}/lib/dri
Name: dri
Description: Direct Rendering Infrastructure (build stub; runtime drivers provided separately)
Version: ${PKG_VERSION}
Cflags:
Libs:
EOF

# The xserver GLX sources (#include <GL/internal/dri_interface.h>) need Mesa's
# DRI loader interface header to compile. conda-forge's Mesa (mesalib) is built
# with the DRI/GLX frontend disabled and does not ship it, so we vendor a copy
# (MIT-licensed, from Mesa 26.1.2) alongside the recipe. It is placed in the
# host include tree only for the build and removed before packaging. At runtime
# GLX loads a Mesa software DRI driver (swrast_dri.so) from DRI_DRIVER_PATH,
# supplied separately (system Mesa, or a future conda mesa-dri-drivers package).
mkdir -p "${PREFIX}/include/GL/internal"
cp "${RECIPE_DIR}/dri_interface.h" "${PREFIX}/include/GL/internal/dri_interface.h"

# Build only the Xvfb DDX. Disabling Xorg/Xnest/Xephyr drops the GPU/DRM
# dependency stack (libdrm, udev, libpciaccess, glamor, ...).
meson setup builddir ${MESON_ARGS} \
    -Dxvfb=true \
    -Dxorg=false \
    -Dxnest=false \
    -Dxephyr=false \
    -Dxwin=false \
    -Dglamor=false \
    -Ddri1=false \
    -Ddri2=false \
    -Ddri3=false \
    -Ddrm=false \
    -Dpciaccess=false \
    -Dudev=false \
    -Dudev_kms=false \
    -Dsystemd_logind=false \
    -Dlibunwind=false \
    -Ddtrace=false \
    -Dsecure-rpc=false \
    -Dxvmc=false \
    -Ddocs=false \
    -Ddevel-docs=false \
    -Ddocs-pdf=false \
    -Dglx=true \
    -Dsha1=libcrypto \
    -Ddefault_font_path=built-ins \
    -Dxkb_dir="${PREFIX}/share/X11/xkb" \
    -Dxkb_bin_dir="${PREFIX}/bin" \
    -Dxkb_output_dir="${PREFIX}/share/X11/xkb/compiled"

meson compile -C builddir -j ${CPU_COUNT}
meson install -C builddir

# Remove the build-only dri.pc stub and vendored dri_interface.h so they are not
# shipped (DRI_DRIVER_PATH is already baked into the server at configure time).
rm -f "${PREFIX}/lib/pkgconfig/dri.pc"
rm -f "${PREFIX}/include/GL/internal/dri_interface.h"
rmdir "${PREFIX}/include/GL/internal" 2>/dev/null || true

# Requires.private and Libs.private are not meaningful in the context of
# shared libraries on conda-forge; strip them from any installed .pc files.
# https://github.com/conda-forge/conda-forge.github.io/issues/1880#issuecomment-3677840586
if [ -d "${PREFIX}/lib/pkgconfig" ]; then
  find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
      -e '/^Requires\.private/d' \
      -e '/^Libs\.private/d' \
      {} +
  find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete
fi

# Man pages / docs are not useful inside a conda environment.
rm -rf "${PREFIX}/share/man" "${PREFIX}/share/doc"
