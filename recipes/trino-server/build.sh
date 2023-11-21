#!/bin/bash

set -euxo pipefail

# Don't build docs (requires Docker).
sed -E -i'' -e 's@.+<module>docs</module>@@g' pom.xml

# Build Trino.
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

# TODO docs
# Copy to $PREFIX/opt/trino-server/ and create a launcher wrapper.
# Trino's 'bin/launcher' will be available under the 'trino-server' executable.
cp -r core/trino-server/target/trino-server-*-hardlinks $PREFIX/opt/trino-server
mkdir -p $PREFIX/opt/trino-server/jars
if which md5sum; then
  md5prog=md5sum
else
  # macOS
  md5prog="md5 -q"
fi
set +x
while IFS= read -r -d '' file; do
  md5ed_path=$PREFIX/opt/trino-server/jars/$($md5prog "$file" | cut -d " " -f 1).jar
  echo "Symlinking $file to $md5ed_path"
  mv "$file" $md5ed_path
  rm -f "$file" # TODO WAT
  ln -s $md5ed_path "$file"
done < <(find $PREFIX/opt/trino-server/plugin -type f -print0)
set -x

executable=$PREFIX/bin/trino-server
echo > $executable 'exec "'$PREFIX'/opt/trino-server/bin/launcher" "$@"'
chmod +x $executable

# Free some disk space for the remainder of the build pipeline.
rm -rf $SRC_DIR/m2
