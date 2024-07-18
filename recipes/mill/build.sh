#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

./mill -i show dev.assembly
install -m 755 out/dev/assembly.dest/mill ${PREFIX}/bin/mill

# Create batch wrapper so that it has a .cmd extension and is recognized as executable
tee ${PREFIX}/bin/mill.cmd << EOF
call %CONDA_PREFIX%\libexec\mill\mill %*
EOF

./mill -i show dev.publishM2Local ${SRC_DIR}/m2
pom_file=$(find ${SRC_DIR}/m2 -name "*.pom")
mv ${pom_file} $(dirname ${pom_file})/pom.xml

cd $(dirname ${pom_file})

# Add exclusion for build-only dependency which does not provide an upstream JAR
tee exclusions.xml << EOF
<exclusions>
    <exclusion>
        <groupId>com.kohlschutter.junixsocket</groupId>
        <artifactId>junixsocket-core</artifactId>
    </exclusion>
</exclusions>
EOF
sed -i "s?<dependency>?<dependency>$(tr -d '\n' < exclusions.xml)?" pom.xml

# Download licenses and move them to ${SRC_DIR}
mvn license:download-licenses -Dgoal=download-licenses
mv target ${SRC_DIR}
