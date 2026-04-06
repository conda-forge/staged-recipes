#!/bin/bash
set -eux -o pipefail

INSTALL_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${INSTALL_DIR}" "${PREFIX}/bin"

# Build with the Gradle wrapper (downloads Gradle + dependencies from Maven Central)
./gradlew :hydra-java:build :hydra-ext:build -x test --no-daemon --stacktrace

# Copy project JARs
cp hydra-java/build/libs/*.jar "${INSTALL_DIR}/"
cp hydra-ext/build/libs/*.jar "${INSTALL_DIR}/" 2>/dev/null || true

# Copy runtime dependencies via a Gradle init script
cat > /tmp/copy-deps.gradle << 'EOF'
allprojects {
    tasks.register('copyDeps', Copy) {
        from configurations.runtimeClasspath
        into System.getenv('INSTALL_DIR')
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE
    }
}
EOF
INSTALL_DIR="${INSTALL_DIR}" ./gradlew :hydra-java:copyDeps \
    --init-script /tmp/copy-deps.gradle --no-daemon

# Install wrapper script
cp "${RECIPE_DIR}/wrapper.sh" "${PREFIX}/bin/hydra-java"
chmod +x "${PREFIX}/bin/hydra-java"
