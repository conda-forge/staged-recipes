#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

ant abcl.properties.autoconfigure.openjdk.8
ant

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/abcl
install -m 644 dist/abcl.jar ${PREFIX}/libexec/abcl
install -m 644 dist/abcl-contrib.jar ${PREFIX}/libexec/abcl

tee ${PREFIX}/bin/abcl << EOF
#!/bin/sh
exec rlwrap ${JAVA_HOME}/bin/java -cp ${PREFIX}/libexec/abcl/abcl.jar:"\$CLASSPATH" org.armedbear.lisp.Main "\$@"
EOF
