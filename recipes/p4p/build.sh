#!/bin/bash

cat <<EOF > configure/RELEASE.local
EPICS_BASE=${EPICS_BASE}
EOF

make -j ${CPU_COUNT}

mv ${SRC_DIR}/python*/${EPICS_HOST_ARCH}/p4p ${SP_DIR}/
mv ${SRC_DIR}/bin/${EPICS_HOST_ARCH}/pvagw ${PREFIX}/bin
