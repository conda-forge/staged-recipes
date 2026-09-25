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

# Third-party license report covering the Maven dependencies pulled in to
# build the jar, packaged via about.license_file.
# Reference: https://github.com/conda-forge/tango-atk-panel-feedstock/blob/7d780c4fe3b8d7b7c81e61af966bc99bc749df03/recipe/build.sh#L6-L9
mvn --batch-mode --no-transfer-progress license:aggregate-third-party-report
cp target/reports/aggregate-third-party-report.html .

# Liquibase auto-loads every jar placed in its global library directory
# (LIQUIBASE_HOME/lib, see the liquibase package's share/liquibase/lib/README.txt),
# which is the documented way to install extensions like this one.
mkdir -p "${PREFIX}/share/liquibase/lib"
cp "target/liquibase-postgresql-${PKG_VERSION}.jar" "${PREFIX}/share/liquibase/lib/"
