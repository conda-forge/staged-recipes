#!/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit


export CFLAGS="${CFLAGS} -Wno-declaration-after-statement"

autoreconf --force --verbose --install

./configure \
    --enable-ipv6 \
    --with-defaults \
    --prefix=$PREFIX \
    --with-mib-modules="host ucd-snmp/diskio" \
    --without-rpm \
    --with-openssl=${PREFIX} \
    --without-kmem-usage \
    --disable-embedded-perl \
    --without-perl-modules
make -j${CPU_COUNT}

# Tests currently fail on Linux because net-tools is needed
# and on macOS for obscure reasons. Try re-enabling in the future
# rm testing/fulltests/default/T023snmpv3getMD5DES_simple
# rm testing/fulltests/default/T024snmpv3getSHA1_simple
# rm testing/fulltests/default/T025snmpv3getSHADES_simple
# rm testing/fulltests/default/T200snmpv2cwalkall_simple
# make test

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
