#!/usr/bin/env bash
set -euxo pipefail

SWT_VERSION="4.37"
MAVEN_LOCAL_REPO="${SRC_DIR}/.m2"
mkdir -p "${MAVEN_LOCAL_REPO}"

# Determine platform-specific Maven artifact ID and build directory
case "${target_platform}" in
  linux-64|linux-aarch64)
    SWT_ARTIFACT_ID="org.eclipse.swt.gtk.linux"
    BUILD_SUBDIR="tuxguitar-linux-swt"
    BUILD_TARGET_SUFFIX="linux-swt"
    ;;
  osx-64)
    SWT_ARTIFACT_ID="org.eclipse.swt.cocoa.macosx"
    BUILD_SUBDIR="tuxguitar-macosx-swt-cocoa"
    BUILD_TARGET_SUFFIX="macosx-swt-cocoa"
    ;;
  osx-arm64)
    SWT_ARTIFACT_ID="org.eclipse.swt.cocoa.macosx"
    BUILD_SUBDIR="tuxguitar-macosx-swt-cocoa"
    BUILD_TARGET_SUFFIX="macosx-swt-cocoa"
    ;;
  *)
    echo "Unsupported platform: ${target_platform}" >&2
    exit 1
    ;;
esac

# Install SWT into the local Maven repo using the artifact ID that TuxGuitar's pom.xml expects
mvn install:install-file \
    -Dmaven.repo.local="${MAVEN_LOCAL_REPO}" \
    -DgroupId=org.eclipse.swt \
    -DartifactId="${SWT_ARTIFACT_ID}" \
    -Dversion="${SWT_VERSION}" \
    -Dpackaging=jar \
    -Dfile="${SRC_DIR}/swt/swt.jar"

# Build TuxGuitar with native audio modules
BUILD_DIR="${SRC_DIR}/src/desktop/build-scripts/${BUILD_SUBDIR}"
cd "${BUILD_DIR}"

mvn -e clean verify -P native-modules \
    -Dmaven.repo.local="${MAVEN_LOCAL_REPO}"

# Install assembled application to PREFIX
# Use a glob to find the output dir — the Maven pom.xml version may differ from PKG_VERSION
if [[ "${target_platform}" == osx-* ]]; then
    DIST_DIR=$(echo "${BUILD_DIR}/target/tuxguitar-"*"-${BUILD_TARGET_SUFFIX}.app")
    INSTALL_DIR="${PREFIX}/opt/tuxguitar"
    mkdir -p "${INSTALL_DIR}"
    # Extract Contents/MacOS/ only — skip the .app bundle wrapper and macOS metadata
    cp -r "${DIST_DIR}/Contents/MacOS/" "${INSTALL_DIR}/"
    # The bundled launcher hardcodes ./jre/bin/java; replace with plain `java` from PATH
    sed -i.bak 's|JAVA="./jre/bin/java"|JAVA="java"|' \
        "${INSTALL_DIR}/tuxguitar.sh"
    rm -f "${INSTALL_DIR}/tuxguitar.sh.bak"
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/tuxguitar" <<'LAUNCHER'
#!/usr/bin/env bash
exec "${CONDA_PREFIX}/opt/tuxguitar/tuxguitar.sh" "$@"
LAUNCHER
    chmod +x "${PREFIX}/bin/tuxguitar"
else
    DIST_DIR=$(echo "${BUILD_DIR}/target/tuxguitar-"*"-${BUILD_TARGET_SUFFIX}")
    mkdir -p "${PREFIX}/opt/tuxguitar"
    cp -r "${DIST_DIR}/" "${PREFIX}/opt/tuxguitar/"
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/tuxguitar" <<'LAUNCHER'
#!/usr/bin/env bash
exec "${CONDA_PREFIX}/opt/tuxguitar/tuxguitar.sh" "$@"
LAUNCHER
    chmod +x "${PREFIX}/bin/tuxguitar"
fi
