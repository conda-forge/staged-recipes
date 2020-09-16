#!/bin/bash

# Maven based build doesn't work on Linux / Azure right now because of glibc issue
mvn clean
mvn process-resources
mvn package -DskipTests

mkdir inner_work_folder
mv $SRC_DIR/packaging/target/openrefine-linux-${PKG_VERSION}.tar.gz inner_work_folder/
cd inner_work_folder
tar -xvf openrefine-linux-${PKG_VERSION}.tar.gz

mkdir -p $PREFIX/opt/
mkdir -p $PREFIX/bin/
mv openrefine-${PKG_VERSION} $PREFIX/opt/openrefine

cat > $PREFIX/bin/refine <<EOL
$PREFIX/opt/openrefine/refine "$@"
EOL

chmod u+x $PREFIX/bin/refine
