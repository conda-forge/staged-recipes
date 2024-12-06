#!/bin/bash

env

set

# Budowanie projektu za pomocą Gradle
sh ./gradlew clean build jar createDependenciesJar

# Tworzenie docelowego katalogu dla Conda
mkdir -p $PREFIX/bin

# Kopiowanie pliku JAR
cp build/libs/*.jar $PREFIX/bin/

# Tworzenie skryptu startowego
echo -e "#!/bin/bash\njava -jar $PREFIX/bin/hpv-kite-1.0.jar \"\$@\"" > $PREFIX/bin/hpv-kite
chmod +x $PREFIX/bin/hpv-kite

