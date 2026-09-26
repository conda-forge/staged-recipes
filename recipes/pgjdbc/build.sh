#!/usr/bin/env bash
set -euxo pipefail

REPO="${SRC_DIR}/.m2-repository"

# Build the driver; 0001-shade-scram-into-the-driver-jar.patch bundles the SCRAM
# client under org.postgresql.shaded, the same layout as the published jar.
mvn --batch-mode --no-transfer-progress -Dmaven.repo.local="${REPO}" package \
    -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

# License texts of the four shaded OnGres libraries (packaged via about.license_file).
mvn --batch-mode --no-transfer-progress -Dmaven.repo.local="${REPO}" \
    dependency:unpack-dependencies \
    -DincludeGroupIds=com.ongres.scram,com.ongres.stringprep \
    -Dmdep.useSubDirectoryPerArtifact=true -Dmdep.stripVersion=true \
    -Dmdep.unpack.includes=META-INF/LICENSE \
    -DoutputDirectory=third-party-licenses

# Liquibase auto-loads every jar in its global library directory (LIQUIBASE_HOME/lib),
# the same place conda-forge's liquibase-postgresql installs to.
mkdir -p "${PREFIX}/share/liquibase/lib"
cp "target/postgresql-${PKG_VERSION}.jar" "${PREFIX}/share/liquibase/lib/postgresql.jar"
