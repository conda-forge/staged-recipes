#!/usr/bin/env bash
set -euxo pipefail

VERSION_PROPERTIES=liquibase-standard/src/main/resources/liquibase.build.properties
sed "s/^build.version=DEV$/build.version=${PKG_VERSION}/" \
    "${VERSION_PROPERTIES}" > "${VERSION_PROPERTIES}.tmp"
mv "${VERSION_PROPERTIES}.tmp" "${VERSION_PROPERTIES}"

mvn --batch-mode --no-transfer-progress versions:set \
    -DnewVersion="${PKG_VERSION}" -DgenerateBackupPoms=false
mvn --batch-mode --no-transfer-progress -pl liquibase-dist -am package \
    -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

mkdir -p "${PREFIX}/share/liquibase" "${PREFIX}/bin" "${PREFIX}/Scripts"
tar -xzf "liquibase-dist/target/liquibase-${PKG_VERSION}.tar.gz" \
    -C "${PREFIX}/share/liquibase"
test -f "${PREFIX}/share/liquibase/internal/lib/liquibase-core.jar"
install -m 755 "${RECIPE_DIR}/liquibase" "${PREFIX}/bin/liquibase"
install -m 644 "${RECIPE_DIR}/liquibase.bat" "${PREFIX}/Scripts/liquibase.bat"