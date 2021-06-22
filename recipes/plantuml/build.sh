#!/usr/bin/env bash
set -eux

export MAVEN_OPTS="-Xmx1G"

cd $SRC_DIR

mvn --batch-mode versions:set "-DnewVersion=v${PKG_VERSION}"
mvn --batch-mode -Dmaven.javadoc.skip=true -Dmaven.source.skip=true package

cp "${SRC_DIR}/target/plantuml-v${PKG_VERSION}.jar" "${PREFIX}/lib/"

echo '#!/bin/bash' > $PREFIX/bin/plantuml
echo 'java -Xmx500M -jar "'$PREFIX'/lib/plantuml-v'$PKG_VERSION'.jar" "$@"' >> $PREFIX/bin/plantuml
chmod +x "${PREFIX}/bin/plantuml"
