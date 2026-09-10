#!/usr/bin/env bash
set -euxo pipefail

VERSION_PROPERTIES=liquibase-standard/src/main/resources/liquibase.build.properties
while IFS= read -r property_line || [[ -n "${property_line}" ]]; do
    printf '%s\n' "${property_line/build.version=DEV/build.version=${PKG_VERSION}}"
done < "${VERSION_PROPERTIES}" > "${VERSION_PROPERTIES}.tmp"
mv "${VERSION_PROPERTIES}.tmp" "${VERSION_PROPERTIES}"

MAVEN=mvn
if [[ "${build_platform:?}" == win-* ]]; then
    MAVEN=mvn.cmd
fi

"${MAVEN}" --batch-mode --no-transfer-progress versions:set \
    -DnewVersion="${PKG_VERSION}" -DgenerateBackupPoms=false
"${MAVEN}" --batch-mode --no-transfer-progress -pl liquibase-dist -am package \
    -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

mkdir -p "${PREFIX}/share/liquibase" "${PREFIX}/bin" "${PREFIX}/Scripts"
tar -xzf "liquibase-dist/target/liquibase-${PKG_VERSION}.tar.gz" \
    -C "${PREFIX}/share/liquibase"
test -f "${PREFIX}/share/liquibase/internal/lib/liquibase-core.jar"
cp "${RECIPE_DIR}/liquibase" "${PREFIX}/bin/liquibase"
cp "${RECIPE_DIR}/liquibase.bat" "${PREFIX}/Scripts/liquibase.bat"
if [[ "${build_platform:?}" != win-* ]]; then
    chmod 755 "${PREFIX}/bin/liquibase"
    chmod 644 "${PREFIX}/Scripts/liquibase.bat"
fi