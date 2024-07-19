#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}/lib
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/zsh/site-functions

# Use bootstrap JAR to build leiningen-core
pushd leiningen-core
    java -jar ../${PKG_NAME}-${PKG_VERSION}-standalone.jar -m leiningen.core.main bootstrap
popd

# Use newly built leiningen-core to build uberjar
./bin/lein uberjar

install -m 644 target/leiningen-${PKG_VERSION}-standalone.jar ${PREFIX}/libexec/${PKG_NAME}/lib
sed -i "s?/usr/share/java?${PREFIX}/libexec/${PKG_NAME}/lib?g" bin/lein-pkg
install -m 755 bin/lein-pkg ${PREFIX}/libexec/${PKG_NAME}/bin/lein

# Create bash and batch wrappers
tee ${PREFIX}/bin/lein << EOF
#/bin/sh
exec \${CONDA_PREFIX}/libexec/leiningen/bin/lein "\$@"
EOF

tee ${PREFIX}/bin/lein.cmd << EOF
call %CONDA_PREFIX%\libexec\leiningen\bin\lein %*
EOF

install -m 644 bash_completion.bash ${PREFIX}/etc/bash_completion.d/lein-completion.bash
install -m 644 zsh_completion.zsh ${PREFIX}/share/zsh/site-functions/_lein

# Use leiningen-core to make pom.xml
./bin/lein pom

# Download dependency licenses with maven
mvn license:download-licenses -Dgoal=download-licenses
