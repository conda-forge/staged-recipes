#!/usr/bin/env bash
set -ex

# writable dir for xkbcomp's compiled keymaps at runtime
mkdir -p "${PREFIX}/share/X11/xkb/compiled"
touch "${PREFIX}/share/X11/xkb/compiled/.keep"

# stub dri.pc so meson resolves dependency('dri'); sets DRI_DRIVER_PATH
mkdir -p "${PREFIX}/lib/pkgconfig"
cat > "${PREFIX}/lib/pkgconfig/dri.pc" <<EOF
dridriverdir=${PREFIX}/lib/dri
Name: dri
Description: Direct Rendering Infrastructure
Version: ${PKG_VERSION}
Cflags:
Libs:
EOF

# vendored Mesa header (conda mesalib does not ship it) so GLX compiles
mkdir -p "${PREFIX}/include/GL/internal"
cp "${RECIPE_DIR}/dri_interface.h" "${PREFIX}/include/GL/internal/dri_interface.h"

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

# drop the build-only stub + vendored header
rm -f "${PREFIX}/lib/pkgconfig/dri.pc"
rm -f "${PREFIX}/include/GL/internal/dri_interface.h"
rmdir "${PREFIX}/include/GL/internal" 2>/dev/null || true

# https://github.com/conda-forge/conda-forge.github.io/issues/1880
if [ -d "${PREFIX}/lib/pkgconfig" ]; then
  find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
      -e '/^Requires\.private/d' \
      -e '/^Libs\.private/d' \
      {} +
  find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete
fi

rm -rf "${PREFIX}/share/man" "${PREFIX}/share/doc"
