#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s?<arg>-Werror<arg>??g" pom.xml

# Build archive with jar and other files
${PYTHON} -u tools/createCompletionLists.py
mvn -B -e clean compile package -DskipTests=True

# Extract newly built archive
tar xzf target/ltex-ls-${PKG_VERSION}.tar.gz -C .

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
cp -r ltex-ls-${PKG_VERSION}/* ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch wrappers for ltex-ls and ltex-cli
tee ${PREFIX}/bin/ltex-cli << EOF
exec \${CONDA_PREFIX}/libexec/ltex-ls/bin/ltex-cli "\$@"
EOF

tee ${PREFIX}/bin/ltex-ls << EOF
exec \${CONDA_PREFIX}/libexec/ltex-ls/bin/ltex-ls "\$@"
EOF

tee ${PREFIX}/bin/ltex-cli.cmd << EOF
call %CONDA_PREFIX%\libexec\ltex-ls\bin\ltex-cli.bat %*
EOF

tee ${PREFIX}/bin/ltex-ls.cmd << EOF
call %CONDA_PREFIX%\libexec\ltex-ls\bin\ltex-ls.bat %*
EOF

# Download licenses for dependencies
mvn license:download-licenses -Dgoal=download-licenses
