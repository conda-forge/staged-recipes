#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build JAR files with sbt
# Create pom.xml files so maven can be used to download licenses
sbt 'set baseVersionSuffix := ""' dist/mkPack makePom

mkdir -p ${SRC_DIR}/target/generated-resources/licenses
filename=scala-dist-${PKG_VERSION}.pom
pom_file=${SRC_DIR}/target/scala-dist/${filename}

pushd $(dirname ${pom_file})
mv ${filename} pom.xml
sed -i 's/scala-library-all/scala-library/' pom.xml
mvn license:download-licenses -Dgoal=download-licenses
cp ./target/generated-resources/licenses/* ${SRC_DIR}/target/generated-resources/licenses
popd

# Install JAR files
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/scala2

cp -r ./build/pack/* ${PREFIX}/libexec/scala2/

for FILE in fsc scala scalac scaladoc scalap; do
    tee ${PREFIX}/bin/${FILE} << EOF
#!/bin/sh
LAUNCHER_PATH="\$(cd -- "\$(dirname "\$0")/../libexec/scala2/bin" >/dev/null 2>&1 ; pwd -P)"
exec \${LAUNCHER_PATH}/${FILE} "\$@"
EOF
    chmod +x ${PREFIX}/bin/${FILE}

    tee ${PREFIX}/bin/${FILE}.bat << EOF
@echo off
"%~dp0..\libexec\scala2\bin\${FILE}.bat" %*
EOF
done

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    for ext in ".sh" ".bat" ".ps1" "-win.sh"; do
        cp "${RECIPE_DIR}/scripts/${CHANGE}${ext}" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}${ext}"
    done
done
