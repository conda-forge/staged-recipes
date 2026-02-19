#!/bin/bash

./configure \
    --with-defaults \
    --prefix=$PREFIX
make
make test
make install

mkdir -p $PREFIX/etc/conda/activate.d
cat <<EOF > $PREFIX/etc/conda/activate.d/net-snmp_activate.sh
NETSNMPMIBDIR="${PREFIX}/share/snmp/mibs"
[  -z "\$MIBDIRS" ] && export MIBDIRS="\$NETSNMPMIBDIR" || export MIBDIRS="\$MIBDIRS:\$NETSNMPMIBDIR"
EOF

mkdir -p $PREFIX/etc/conda/deactivate.d
cat <<EOF > $PREFIX/etc/conda/deactivate.d/net-snmp_deactivate.sh
NETSNMPMIBDIR="${PREFIX}/share/snmp/mibs"
export MIBDIRS=\$(echo -n \$MIBDIRS | tr ":" "\n" | grep -xv "\$NETSNMPMIBDIR" | tr "\n" ":" | rev | cut -c 2- | rev)
EOF
