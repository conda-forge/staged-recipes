#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

# Build JAR file with maven
mvn -Plocal -Dmaven.test.skip=true package

# Download licenses
mvn license:download-licenses -Dgoal=download-licenses

cp ${PKG_NAME}.jar ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers
tee ${PREFIX}/bin/clojure << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/clojure/clojure.jar "\$@"
EOF

ln -sf ${PREFIX}/bin/clojure ${PREFIX}/bin/clj

tee ${PREFIX}/bin/clojure.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX\libexec\clojure\clojure.jar %*
EOF

tee ${PREFIX}/bin/clj.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX\libexec\clojure\clojure.jar %*
EOF
