#!/usr/bin/env bash
set -euxo pipefail

# The build inherits the buildnumber-maven-plugin from liquibase-parent-pom,
# which records the source git revision and fails outside of a git checkout.
# The release tarball has no .git directory, so create a throwaway one.
# Refer: https://github.com/liquibase/liquibase-parent-pom/blob/v1.0.2/pom.xml#L417-L434
git init -q
git -c user.email="build.user@xyz.com" -c user.name="build.user" add -A
git -c user.email="build.user@xyz.com" -c user.name="build.user" \
    commit -q -m "source" --allow-empty

mvn --batch-mode --no-transfer-progress versions:set \
    -DnewVersion="${PKG_VERSION}" -DgenerateBackupPoms=false
mvn --batch-mode --no-transfer-progress package \
    -Dmaven.test.skip=true -Dmaven.javadoc.skip=true

# Liquibase auto-loads every jar placed in its global library directory
# (LIQUIBASE_HOME/lib, see the liquibase package's share/liquibase/lib/README.txt),
# which is the documented way to install extensions like this one.
mkdir -p "${PREFIX}/share/liquibase/lib"
cp "target/liquibase-postgresql-${PKG_VERSION}.jar" "${PREFIX}/share/liquibase/lib/"
