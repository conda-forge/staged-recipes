#!/bin/bash

# Zatrzymaj przy błędzie
set -o errexit

# Budowanie projektu za pomocą Gradle
sh ./gradlew clean build jar createDependenciesJar

# Tworzenie docelowego katalogu dla Conda
mkdir -p $PREFIX/bin

# Kopiowanie pliku JAR
cp build/libs/*.jar $PREFIX/bin/

# Tworzenie skryptu startowego
tee ${PREFIX}/bin/hpv-kite << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/hpv-kite/hpv-kite-${PKG_VERSION}.jar "\$@"

tee ${PREFIX}/bin/hpv-kite.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\hpv-kite\hpv-kite-${PKG_VERSION}.jar %*
EOF
chmod +x $PREFIX/bin/hpv-kite

