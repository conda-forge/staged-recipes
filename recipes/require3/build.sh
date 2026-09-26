#!/bin/bash

export EPICS_MODULES="${PREFIX}/epics-modules"
export E3_REQUIRE_LOCATION="${EPICS_MODULES}/${PKG_NAME}"
export INSTALL_PREFIX="${PREFIX}"

cat <<EOF > configure/RELEASE.local
EPICS_BASE:=${PREFIX}/epics
PVXS:=${PREFIX}/pvxs
EOF

make clean

make INSTALL_LOCATION=${E3_REQUIRE_LOCATION} \
     INSTALL_BIN=${PREFIX}/bin \
     INSTALL_SHRLIB=${PREFIX}/lib \
     INSTALL_INCLUDE=${PREFIX}/include

# Create activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat <<EOF > "${PREFIX}/etc/conda/activate.d/require3_activate.sh"
export INSTALL_PREFIX="${PREFIX}"
export EPICS_MODULES="${EPICS_MODULES}"
export E3_REQUIRE_VERSION="${PKG_VERSION}"
export E3_REQUIRE_LOCATION="${E3_REQUIRE_LOCATION}"
export E3_REQUIRE_TOOLS="${E3_REQUIRE_LOCATION}/share"
export E3_REQUIRE_BIN="${PREFIX}/bin"
export E3_REQUIRE_LIB="${PREFIX}/lib"
export E3_REQUIRE_INC="${PREFIX}/include"
export E3_REQUIRE_DB="${E3_REQUIRE_LOCATION}/db"
export E3_REQUIRE_DBD="${E3_REQUIRE_LOCATION}/dbd"
export E3_REQUIRE_CONFIG="${E3_REQUIRE_LOCATION}/cfg"
export REQUIRE_MODULE_PATH="${EPICS_MODULES}"

# Add iocsh autocompletion for require3
source "${PREFIX}/bin/iocsh_complete.bash"
EOF

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat <<EOF > "${PREFIX}/etc/conda/deactivate.d/require3_deactivate.sh"
unset EPICS_MODULES
unset E3_REQUIRE_VERSION
unset E3_REQUIRE_LOCATION
unset E3_REQUIRE_TOOLS
unset E3_REQUIRE_BIN
unset E3_REQUIRE_LIB
unset E3_REQUIRE_DB
unset E3_REQUIRE_DBD
unset E3_REQUIRE_INC
unset E3_REQUIRE_CONFIG
unset REQUIRE_MODULE_PATH
EOF
