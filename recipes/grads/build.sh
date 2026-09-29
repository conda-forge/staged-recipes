#!/bin/bash
set -euxo pipefail

# Regenerate configure so the portability patch is reflected in release
# archives that also ship pregenerated Autotools files.
autoreconf -fi

configure_args=(
  --prefix="${PREFIX}"
  --with-netcdf="${PREFIX}"
  --with-hdf5="${PREFIX}"
  --enable-dyn-supplibs
  GD_CFLAGS="-I${PREFIX}/include"
  GD_LIBS="-L${PREFIX}/lib -lgd"
  CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/freetype2"
  LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
)

# conda-forge's macOS cairo build does not include cairo-xlib.h. Let the
# configure probe disable Cairo there while retaining native X11 and GD.
if [[ "$(uname -s)" != "Darwin" ]]; then
  configure_args+=(
    CAIRO_CFLAGS="-I${PREFIX}/include/cairo -I${PREFIX}/include/freetype2"
    CAIRO_LIBS="-L${PREFIX}/lib -lcairo"
  )
fi

SUPPLIBS="${PREFIX}" ./configure "${configure_args[@]}"

make -j"${CPU_COUNT:-1}"
make install

find "${PREFIX}/lib" -name '*.la' -delete

mkdir -p "${PREFIX}/share/grads"
cp -r data/* "${PREFIX}/share/grads/"

if [[ "$(uname -s)" == "Darwin" ]]; then
  shared_ext="dylib"
else
  shared_ext="so"
fi

cat > "${PREFIX}/share/grads/udpt" <<EOF
# Type     Name     Full path to shared object file
EOF

if grep -q '^#define USECAIRO 1' src/config.h; then
  cat >> "${PREFIX}/share/grads/udpt" <<EOF
gxdisplay  Cairo    ${PREFIX}/lib/libgxdCairo.${shared_ext}
EOF
fi

cat >> "${PREFIX}/share/grads/udpt" <<EOF
gxdisplay  X11      ${PREFIX}/lib/libgxdX11.${shared_ext}
gxdisplay  gxdummy  ${PREFIX}/lib/libgxdummy.${shared_ext}
*
EOF

if grep -q '^#define USECAIRO 1' src/config.h; then
  cat >> "${PREFIX}/share/grads/udpt" <<EOF
gxprint    Cairo    ${PREFIX}/lib/libgxpCairo.${shared_ext}
EOF
fi

cat >> "${PREFIX}/share/grads/udpt" <<EOF
gxprint    GD       ${PREFIX}/lib/libgxpGD.${shared_ext}
gxprint    gxdummy  ${PREFIX}/lib/libgxdummy.${shared_ext}
EOF

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

cat > "${PREFIX}/etc/conda/activate.d/grads-env.sh" <<EOF
#!/bin/bash
export GADDIR_BACKUP="\${GADDIR}"
export GAUDPT_BACKUP="\${GAUDPT}"
export GAGPY_BACKUP="\${GAGPY}"
export GADDIR="${PREFIX}/share/grads"
export GAUDPT="${PREFIX}/share/grads/udpt"
export GAGPY="${PREFIX}/lib/libgradspy.${shared_ext}"
EOF

cat > "${PREFIX}/etc/conda/deactivate.d/grads-env.sh" <<'EOF'
#!/bin/bash
export GADDIR="${GADDIR_BACKUP}"
export GAUDPT="${GAUDPT_BACKUP}"
export GAGPY="${GAGPY_BACKUP}"
unset GADDIR_BACKUP
unset GAUDPT_BACKUP
unset GAGPY_BACKUP
EOF
