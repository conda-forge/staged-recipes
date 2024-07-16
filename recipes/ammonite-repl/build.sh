#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Build JAR files with mill
latest_version=$(./mill resolve amm[__] | tail -n 1 | sed -e 's/amm\[//' | sed -e 's/\]//')
./mill -i amm[${latest_version}].assembly
install -m 644 out/amm/${latest_version}/assembly.dest/out.jar ${PREFIX}/libexec/${PKG_NAME}/ammonite-repl.jar

# Create bash and batch wrappers
tee ${PREFIX}/bin/amm << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/ammonite-repl/ammonite-repl.jar "\$@"
EOF

tee ${PREFIX}/bin/amm.cmd << EOF
exec %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\ammonite-repl\ammonite-repl.jar %*
EOF

# Create pom.xml files so maven can be used to download licenses
./mill -i amm[${latest_version}].publishM2Local ${SRC_DIR}/m2
pom_file=$(find ${SRC_DIR}/m2 -name "*.pom")
mv ${pom_file} $(dirname ${pom_file})/pom.xml

# Download licenses and move them to ${SRC_DIR}
cd $(dirname ${pom_file})
mvn license:download-licenses -Dgoal=download-licenses
mv target ${SRC_DIR}

exit 1
