#!/usr/bin/env bash
set -eu

mvn -Dmaven.javadoc.skip=true \
    -Dvoms-clients.libs="${PREFIX}/share/voms-clients/lib" \
    package

tar xvf target/voms-clients.tar.gz
cp voms-clients/bin/* "${PREFIX}/bin"

mkdir -p "${PREFIX}/share/voms-clients/lib"
mv voms-clients/share/java/* "${PREFIX}/share/voms-clients/lib"
