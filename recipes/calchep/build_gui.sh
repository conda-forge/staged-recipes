#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o xtrace

echo "toolchain: CC=${CC:-} CXX=${CXX:-} HOST=${HOST:-}"

# This output inherits the staging cache: the fully built (blind) tree plus all
# intermediate objects at ${PREFIX}/share/calchep, built with the conda compiler
# (FlagsForMake still records it here -- the bare-name rewrite happens only in the
# calchep package output). Every library CalcHEP needs is X11-independent and
# identical between the blind and GUI variants; only serv.a (the chep_crt console
# layer) and the front-end binaries that link it differ. So we re-link just the
# interactive s_calchep against X11, reusing the cached X11-independent libraries.
CALCHEP_HOME="${PREFIX}/share/calchep"
cd "${CALCHEP_HOME}"

# Enable X11 for the re-link. xorg-libx11 (host dependency) provides the headers
# under ${PREFIX}/include and libX11 under ${PREFIX}/lib.
sed -i -E \
  -e "s|^HX11 = .*|HX11 = -I${PREFIX}/include|" \
  -e "s|^LX11 = .*|LX11 = -L${PREFIX}/lib -lX11|" \
  FlagsForMake

# Rebuild only chep_crt's objects. chep_crt's Makefile ``ar``-replaces just its
# own objects in the shared serv.a (swapping the stub noxwin/X11_crt0.o for the
# real xwin/X11_crt0.o), keeping service2's objects (writeF, pathtocalchep, ...).
# Then re-link the symbolic front-end (s_calchep, make_VandP, ...) against the
# cached X11-independent libraries + libX11.
rm -f c_source/chep_crt/*.o bin/s_calchep
make -C c_source/chep_crt </dev/null
make -C c_source/symb </dev/null

# Install the X11-enabled s_calchep into the calchep-gui package's own location.
# Its compiled-in rootDir points at share/calchep, whose data/libraries are
# supplied by the calchep run dependency.
mkdir -p "${PREFIX}/share/calchep-gui/bin" "${PREFIX}/bin"
cp -a bin/s_calchep "${PREFIX}/share/calchep-gui/bin/s_calchep"
ln -s "../share/calchep-gui/bin/s_calchep" "${PREFIX}/bin/calchep-gui"
