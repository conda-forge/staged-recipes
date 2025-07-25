#!/bin/bash

cat <<EOF > configure/RELEASE.local
EPICS_BASE=${EPICS_BASE}
EOF

make install

install -d ${PREFIX}/include/pvxs ${PREFIX}/bin/ ${PREFIX}/lib/ ${PREFIX}/pvxs/dbd ${PREFIX}/pvxs/db
install bin/${EPICS_HOST_ARCH}/* ${PREFIX}/bin/
install lib/${EPICS_HOST_ARCH}/*.so* ${PREFIX}/lib/
install -m 0664 include/pvxs/* ${PREFIX}/include/pvxs/
install -m 0664 dbd/* ${PREFIX}/pvxs/dbd
install -m 0664 db/* ${PREFIX}/pvxs/db

mkdir -p $PREFIX/etc/conda/activate.d
cat <<EOF > $PREFIX/etc/conda/activate.d/pvxs_activate.sh
export PVXS="${PREFIX}/pvxs/"
EOF

mkdir -p $PREFIX/etc/conda/deactivate.d
cat <<EOF > $PREFIX/etc/conda/deactivate.d/pvxs_deactivate.sh
unset PVXS
EOF
