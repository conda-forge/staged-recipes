#!/bin/bash
set -euo pipefail

# Build
cd "$SRC_DIR"
mkdir -p "$PREFIX/lib" "$PREFIX/bin"

mvn clean package 
cp "$SRC_DIR/target/denoptim-$PKG_VERSION-jar-with-dependencies.jar" "$PREFIX/lib"

echo '#!/bin/bash' > "$PREFIX/bin/denoptim"
echo 'java -jar "'$PREFIX'/lib/denoptim-'$PKG_VERSION'-jar-with-dependencies.jar" "$@"' >> "$PREFIX/bin/denoptim"

chmod +x "${PREFIX}/bin/denoptim"
rm -rf "${PREFIX}/var/cache/"*
