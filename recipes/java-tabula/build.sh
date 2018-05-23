#!/usr/bin/env bash

export MAVEN_OPTS="-Xmx1G"

mvn clean compile assembly:single

cp target/tabula-${PKG_VERSION}-jar-with-dependencies.jar $PREFIX/lib/tabula.jar 

echo '#!/bin/bash' > $PREFIX/bin/tabula
echo 'exec java -jar "'$PREFIX'/lib/tabula.jar" "$@"' >> $PREFIX/bin/tabula
chmod +x $PREFIX/bin/tabula 
