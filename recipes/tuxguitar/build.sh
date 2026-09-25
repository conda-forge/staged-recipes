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

if [[ "${target_platform}" == linux-* ]]; then
    NATIVE_DIR="${SRC_DIR}/src/desktop/build-scripts/native-modules"

    # The upstream pom.xml files for native modules hardcode CC=gcc and
    # LDPATH=-L/usr/lib, which break in the conda build environment where:
    #  - the compiler is the conda-provided toolchain (e.g. x86_64-conda-linux-gnu-gcc)
    #  - headers and libraries are under $PREFIX, not /usr/{include,lib}
    # Fix CC, CFLAGS (add $PREFIX/include), and LDPATH for alsa and fluidsynth.
    for pom in \
        "${NATIVE_DIR}/tuxguitar-alsa-linux/pom.xml" \
        "${NATIVE_DIR}/tuxguitar-fluidsynth-linux/pom.xml"
    do
        sed -i \
            -e "s|value=\"gcc\"|value=\"${CC}\"|g" \
            -e "s|value=\"-I\${basedir}/../common-include -fPIC\"|value=\"-I\${basedir}/../common-include -I${PREFIX}/include -fPIC\"|g" \
            -e "s|value=\"-L/usr/lib\"|value=\"-L${PREFIX}/lib\"|g" \
            "${pom}"
    done

    # Jack: same fixes, plus replace the backtick pkg-config expression for LDLIBS
    # with a literal -ljack (Maven/Ant does not shell-expand backticks in <env> values).
    sed -i \
        -e "s|value=\"gcc\"|value=\"${CC}\"|g" \
        -e "s|value=\"-I\${basedir}/../common-include -fPIC\"|value=\"-I\${basedir}/../common-include -I${PREFIX}/include -fPIC\"|g" \
        -e "s|value=\"-L/usr/lib\"|value=\"-L${PREFIX}/lib\"|g" \
        -e 's|value="`pkg-config --libs jack`"|value="-ljack"|g' \
        "${NATIVE_DIR}/tuxguitar-jack-linux/pom.xml"

    # lv2 requires lilv/suil/Qt5 which are not available on conda-forge.
    # Remove the lv2 <module> entry, its <copy> block, and the <chmod> on
    # lv2 binaries from the tuxguitar-linux-swt build POM.  A dedicated
    # Python script handles this because the <copy> block spans multiple
    # lines and a simple per-line sed delete leaves behind an empty
    # <copy></copy> that Ant rejects with "Specify at least one source".
    LINUX_SWT_POM="${SRC_DIR}/src/desktop/build-scripts/tuxguitar-linux-swt/pom.xml"
    python3 "${RECIPE_DIR}/patch_lv2.py" "${LINUX_SWT_POM}"
fi

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
