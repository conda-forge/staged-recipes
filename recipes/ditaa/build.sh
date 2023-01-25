#!/bin/sh

# if some command fails, abort immediately
set -ex

# copy to library
JAR=ditaa-0.11.0-standalone.jar
cp -v ./$JAR ${PREFIX}/lib

# create executable
echo "
#!/bin/sh
java -ea -jar \${CONDA_PREFIX}/lib/$JAR \"\$@\"
" > ${PREFIX}/bin/ditaa
chmod +x ${PREFIX}/bin/ditaa
