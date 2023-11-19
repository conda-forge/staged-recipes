#!/bin/bash

set -euxo pipefail

# Don't build docs (requires Docker).
sed -i'' -e 's@<module>docs</module>@@g' pom.xml

# Build and install to ./core/...
if [[ "$build_platform" =~ linux ]]; then
  parallel="-T$CPU_COUNT"
else
  # https://issues.apache.org/jira/browse/MNG-7868
  parallel=""
fi
./mvnw clean install --no-transfer-progress -DskipTests -Dmaven.repo.local=$SRC_DIR/m2 $parallel

# Collect third-party licenses.
# Trino ships its own third-party license file at "core/.../trino-server-*/NOTICE"
# so this might be redundant.
./mvnw org.codehaus.mojo:license-maven-plugin:aggregate-add-third-party -Dmaven.repo.local=$SRC_DIR/m2

# Copy ./core/.../trino-server-*/ to $PREFIX/opt/trino-server/ and create a launcher wrapper.
# Trino's 'bin/launcher' will be available under the 'trino-server' executable.
cp -r core/trino-server/target/trino-server-* $PREFIX/opt/trino-server
executable=$PREFIX/bin/trino-server
echo > $executable 'exec "'$PREFIX'/opt/trino-server/bin/launcher" "$@"'
chmod +x $executable

# Free some disk space for the remainder of the build pipeline.
rm -rf $SRC_DIR/m2
