#!/usr/bin/env bash

set -exuo pipefail

mkdir -p $PREFIX/lib/java/PanoplyJ
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/* $PREFIX/lib/java/PanoplyJ/

cat <<EOF >${PREFIX}/bin/panoply
#!/usr/bin/env bash
java -Xms512m -Xmx1600m \$JAVA_OPTS -jar $PREFIX/lib/java/PanoplyJ/jars/Panoply.jar "\$@"
EOF
chmod +x ${PREFIX}/bin/panoply
