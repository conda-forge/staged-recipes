#!/usr/bin/env bash
set -euxo pipefail

# Build copybara using Bazel
# Fetches Maven dependencies during build

# Set up Bazel cache in a writable location
export HOME="${SRC_DIR}"

# Build the deploy JAR
bazel build //java/com/google/copybara:copybara_deploy.jar \
    --java_runtime_version=21 \
    --tool_java_runtime_version=21 \
    --verbose_failures

# Install the JAR
mkdir -p "${PREFIX}/share/copybara"
cp bazel-bin/java/com/google/copybara/copybara_deploy.jar "${PREFIX}/share/copybara/"

# Create wrapper script
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/copybara" << 'EOF'
#!/bin/bash
exec java -jar "${CONDA_PREFIX}/share/copybara/copybara_deploy.jar" "$@"
EOF
chmod +x "${PREFIX}/bin/copybara"

# Collect licenses from all dependencies.
# Uses Maven license-maven-plugin to download actual upstream licenses from POM-specified URLs.
mkdir -p "${SRC_DIR}/library_licenses"

# Generate pom.xml from MODULE.bazel Maven coordinates
mkdir -p "${SRC_DIR}/license-collector"
cd "${SRC_DIR}/license-collector"

MAVEN_DEPS=$(grep -oE '"[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+"' "${SRC_DIR}/MODULE.bazel" | tr -d '"' | sort -u)

cat > pom.xml << 'POMHEADER'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.google.copybara</groupId>
    <artifactId>license-collector</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>
    <dependencies>
POMHEADER

for dep in $MAVEN_DEPS; do
    groupId=$(echo "$dep" | cut -d: -f1)
    artifactId=$(echo "$dep" | cut -d: -f2)
    version=$(echo "$dep" | cut -d: -f3)
    cat >> pom.xml << DEPDOC
        <dependency>
            <groupId>${groupId}</groupId>
            <artifactId>${artifactId}</artifactId>
            <version>${version}</version>
        </dependency>
DEPDOC
done

cat >> pom.xml << 'POMFOOTER'
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>license-maven-plugin</artifactId>
                <version>2.7.1</version>
            </plugin>
        </plugins>
    </build>
</project>
POMFOOTER

echo "Generated pom.xml with $(echo "$MAVEN_DEPS" | wc -w | tr -d ' ') Maven dependencies"

# Download licenses for all dependencies (including transitive)
# Also generates THIRD-PARTY.xml which maps each dependency to its license
mvn license:download-licenses \
    -DlicensesOutputDirectory="${SRC_DIR}/library_licenses/maven" \
    -DlicensesOutputFile="${SRC_DIR}/library_licenses/THIRD-PARTY.xml" \
    -DincludeTransitiveDependencies=true \
    -q || true

cd "${SRC_DIR}"

# Also collect licenses from Bazel external dependencies (grpc, protobuf, rules_*, etc.)
EXTERNAL_DIR="$(bazel info output_base)/external"
if [ -d "$EXTERNAL_DIR" ]; then
    echo "Collecting licenses from Bazel external dependencies..."
    find "$EXTERNAL_DIR" \( \
        -name "LICENSE*" -o -name "LICENCE*" -o -name "NOTICE*" -o -name "COPYING*" \
        \) -type f 2>/dev/null | while read -r license_file; do
        rel_path="${license_file#$EXTERNAL_DIR/}"
        dep_name=$(echo "$rel_path" | cut -d'/' -f1)
        filename=$(basename "$license_file")
        mkdir -p "${SRC_DIR}/library_licenses/bazel/${dep_name}"
        cp "$license_file" "${SRC_DIR}/library_licenses/bazel/${dep_name}/${filename}" 2>/dev/null || true
    done
fi

# Remove empty directories
find "${SRC_DIR}/library_licenses" -type d -empty -delete 2>/dev/null || true

echo "License collection complete. Found $(find "${SRC_DIR}/library_licenses" -type f 2>/dev/null | wc -l) license files."

# Fix permissions on Bazel output directories (Bazel creates read-only files that
# prevent cleanup during the test phase)
chmod -R +w "${SRC_DIR}/bazel-"* 2>/dev/null || true
chmod -R +w "$(bazel info output_base)" 2>/dev/null || true
