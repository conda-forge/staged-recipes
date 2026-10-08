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

# Activate env vars
mkdir -p "${PREFIX}/etc/conda/env_vars.d"
cat <<EOF > "${PREFIX}/etc/conda/env_vars.d/require3.json"
{
  "INSTALL_PREFIX": "${PREFIX}",
  "EPICS_MODULES": "${EPICS_MODULES}",
  "E3_REQUIRE_VERSION": "${PKG_VERSION}",
  "E3_REQUIRE_LOCATION": "${E3_REQUIRE_LOCATION}",
  "E3_REQUIRE_TOOLS": "${E3_REQUIRE_LOCATION}/share",
  "E3_REQUIRE_BIN": "${PREFIX}/bin",
  "E3_REQUIRE_LIB": "${PREFIX}/lib",
  "E3_REQUIRE_INC": "${PREFIX}/include",
  "E3_REQUIRE_DB": "${E3_REQUIRE_LOCATION}/db",
  "E3_REQUIRE_DBD": "${E3_REQUIRE_LOCATION}/dbd",
  "E3_REQUIRE_CONFIG": "${E3_REQUIRE_LOCATION}/cfg",
  "REQUIRE_MODULE_PATH": "${EPICS_MODULES}"
}
EOF
