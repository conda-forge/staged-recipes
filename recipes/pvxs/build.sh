#!/bin/bash

cat <<EOF > configure/RELEASE.local
EPICS_BASE=${EPICS_BASE}
EOF

make install

install -d ${PREFIX}/include/pvxs ${PREFIX}/bin/ ${PREFIX}/lib/ ${PREFIX}/epics/modules/pvxs/dbd
install bin/${EPICS_HOST_ARCH}/* ${PREFIX}/bin/
install lib/${EPICS_HOST_ARCH}/*.so* ${PREFIX}/lib/
install -m 0664 include/pvxs/* ${PREFIX}/include/pvxs/
install -m 0664 dbd/* ${PREFIX}/epics/modules/pvxs/dbd
