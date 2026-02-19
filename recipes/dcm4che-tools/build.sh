#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

./mvnw -Djdk.xml.maxGeneralEntitySizeLimit=0 -Djdk.xml.totalEntitySizeLimit=0 install

mkdir -p ${PREFIX}/libexec/dcm4che-tools
cp -r ${SRC_DIR}/dcm4che-assembly/target/dcm4che-${PKG_VERSION}-bin/dcm4che-${PKG_VERSION}/* ${PREFIX}/libexec/dcm4che-tools

mkdir -p ${PREFIX}/bin
exe_wrapper() {
    exe_name=$1
    tee ${PREFIX}/bin/${exe_name} << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/libexec/dcm4che-tools/bin/${exe_name} "\$@"
EOF
    chmod +x ${PREFIX}/bin/${exe_name}

    tee ${PREFIX}/bin/${exe_name}.bat << EOF
call %CONDA_PREFIX%\libexec\dcm4che-tools\bin\\${exe_name}.bat %*
EOF
}
export -f exe_wrapper
ls ${PREFIX}/libexec/dcm4che-tools/bin | grep -v ".bat" | xargs -I % bash -c "exe_wrapper %"

cd dcm4che-assembly
mvn license:download-licenses -Dgoal=download-licenses
