#!/bin/bash

# Stop on error
set -o errexit

# add dependency-license-report plugin
sed -i "s/^\(\s*\)id 'java'/&\n\1id 'com.github.jk1.dependency-license-report' version 'latest.release'/" build.gradle

# build package with hpv-kite
chmod +x ./gradlew
./gradlew clean build jar createDependenciesJar
./gradlew generateLicenseReport

# create destination folder for conda command and the libraries
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/libexec/hpv-kite/

# copy jar files into output dir
cp build/libs/*.jar $PREFIX/libexec/hpv-kite/

# create executable scripts
tee ${PREFIX}/bin/hpv-kite << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/hpv-kite/hpv-kite-${PKG_VERSION}.jar "\$@"
EOF

tee ${PREFIX}/bin/hpv-kite.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\hpv-kite\hpv-kite-${PKG_VERSION}.jar %*
EOF

chmod +x $PREFIX/bin/hpv-kite
