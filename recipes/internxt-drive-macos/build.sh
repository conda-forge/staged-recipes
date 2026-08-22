#!/usr/bin/env bash
set -o xtrace -o nounset -o pipefail -o errexit

# ============================================================
# Phase 1: Resolve Swift Package Manager dependencies
# ============================================================
# SPM dependencies are declared in the Xcode project and resolved
# automatically by xcodebuild. Force resolution before building.
xcodebuild -resolvePackageDependencies \
    -project InternxtDesktop.xcodeproj \
    -scheme InternxtDesktop \
    -clonedSourcePackagesDirPath "${SRC_DIR}/.swiftpm"

# ============================================================
# Phase 2: Build the app with xcodebuild
# ============================================================
# Build without code signing since conda packages do not require
# Apple code signatures. Users can ad-hoc sign after install.
xcodebuild build \
    -project InternxtDesktop.xcodeproj \
    -scheme InternxtDesktop \
    -configuration Release \
    -derivedDataPath "${SRC_DIR}/build" \
    -clonedSourcePackagesDirPath "${SRC_DIR}/.swiftpm" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    -arch "${OSX_ARCH:-$(uname -m)}" \
    MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-13.0}"

# ============================================================
# Phase 3: Locate the built .app bundle
# ============================================================
APP_BUNDLE=$(find "${SRC_DIR}/build/Build/Products/Release" \
    -name "InternxtDesktop.app" -maxdepth 1 -type d)

if [ -z "${APP_BUNDLE}" ]; then
    echo "ERROR: InternxtDesktop.app not found in build products"
    find "${SRC_DIR}/build/Build/Products" -name "*.app" -type d
    exit 1
fi

echo "Found app bundle: ${APP_BUNDLE}"

# ============================================================
# Phase 4: Install into conda prefix
# ============================================================
INSTALL_DIR="${PREFIX}/Applications"
mkdir -p "${INSTALL_DIR}"

cp -R "${APP_BUNDLE}" "${INSTALL_DIR}/InternxtDesktop.app"

# Create a convenience symlink in bin/
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/internxt-drive-macos" << 'LAUNCHER'
#!/usr/bin/env bash
open "$(dirname "$(dirname "$(readlink -f "$0")")")/Applications/InternxtDesktop.app" "$@"
LAUNCHER
chmod +x "${PREFIX}/bin/internxt-drive-macos"

echo "Build completed successfully."
