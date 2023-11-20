#!/bin/bash

set -euxo pipefail

# Don't build docs (requires Docker).
sed -E -i'' -e 's@.+<module>docs</module>@@g' pom.xml

# Build trino-server-*.tar.gz.
if [[ "$build_platform" =~ linux ]]; then
  parallel="-T$CPU_COUNT"
else
  # https://issues.apache.org/jira/browse/MNG-7868
  parallel=""
fi
MAVEN_OPTS=-Xmx4096m ./mvnw clean install --no-transfer-progress -DskipTests -Dmaven.repo.local=$SRC_DIR/m2 $parallel

# Collect third-party licenses.
# Trino ships its own third-party license file at "core/.../trino-server-*/NOTICE"
# so this might be redundant.
./mvnw org.codehaus.mojo:license-maven-plugin:aggregate-add-third-party -Dmaven.repo.local=$SRC_DIR/m2

# Extract trino-server-*.tar.gz to $PREFIX/opt/trino-server/ and create a launcher wrapper.
# Trino's 'bin/launcher' will be available under the 'trino-server' executable.
mkdir -p $PREFIX/opt/trino-server
tar -C $PREFIX/opt/trino-server --strip-components 1 -xzf core/trino-server/target/trino-server-???.tar.gz
executable=$PREFIX/bin/trino-server
echo > $executable 'exec "'$PREFIX'/opt/trino-server/bin/launcher" "$@"'
chmod +x $executable

# Free some disk space for the remainder of the build pipeline.
rm -rf $SRC_DIR/m2
