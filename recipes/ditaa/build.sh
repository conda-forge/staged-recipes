#!/usr/bin/env bash
set -eux

mkdir -vp ${PREFIX}/bin

cp ${RECIPE_DIR}/lein ./
chmod +x lein
./lein self-install
./lein uberjar

# copy to library
JAR=ditaa-0.11.0-standalone.jar
cp ./target/$JAR "${PREFIX}/lib/ditaa.jar"

echo '#!/bin/bash' > $PREFIX/bin/ditaa
echo 'java -ea -jar ${PREFIX}/lib/ditaa.jar "$@"' >> $PREFIX/bin/ditaa
chmod +x "${PREFIX}/bin/ditaa"
