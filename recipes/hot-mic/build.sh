#!/usr/bin/env bash
set -euo pipefail

# Hot Mic is built with the system Xcode, not conda's clang: it is a
# SwiftUI/AppKit app and conda-forge ships no Swift toolchain. Upstream
# requires Xcode 26 (Swift 6.2) because of the pinned KeyboardShortcuts 3.0.1.
# The Azure macOS image ships several Xcodes with 16.x as the default, so pick
# the newest 26.x explicitly. Outside CI fall back to whatever xcode-select
# points at, as long as it is a full Xcode.
xcode26="$(ls -d /Applications/Xcode_26*.app 2>/dev/null | sort -V | tail -1 || true)"
if [[ -n "${xcode26}" && -d "${xcode26}/Contents/Developer" ]]; then
    export DEVELOPER_DIR="${xcode26}/Contents/Developer"
elif [[ -x "$(xcode-select -p)/usr/bin/xcodebuild" ]]; then
    export DEVELOPER_DIR="$(xcode-select -p)"
else
    echo "error: a full Xcode 26 installation is required to build Hot Mic" >&2
    exit 1
fi
echo "==> Using ${DEVELOPER_DIR}"
xcodebuild -version

# Keep conda's toolchain variables away from xcodebuild.
unset CC CXX OBJC OBJCXX LD AR RANLIB LDFLAGS CFLAGS CXXFLAGS CPPFLAGS SDKROOT CONDA_BUILD_SYSROOT

case "${target_platform}" in
    osx-64) archs="x86_64" ;;
    osx-arm64) archs="arm64" ;;
    *) echo "unsupported target_platform ${target_platform}" >&2; exit 1 ;;
esac

# The project now references the vendored KeyboardShortcuts checkout as a
# local package (see patches/), so the remote pin file is stale.
rm -f Dictation.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

build_dir="${SRC_DIR}/build-conda"
xcodebuild \
    -project Dictation.xcodeproj \
    -scheme Dictation \
    -configuration Release \
    -sdk macosx \
    -destination "generic/platform=macOS" \
    -derivedDataPath "${build_dir}/DerivedData" \
    -clonedSourcePackagesDirPath "${build_dir}/SourcePackages" \
    SYMROOT="${build_dir}" \
    ARCHS="${archs}" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY=- \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES \
    OTHER_CODE_SIGN_FLAGS="--timestamp=none" \
    SWIFT_TREAT_WARNINGS_AS_ERRORS=NO \
    build

app="${build_dir}/Release/Hot Mic.app"
/usr/bin/codesign --verify --deep --strict "${app}"

# Layout:
#   $PREFIX/Applications/Hot Mic.app  full bundle, for Finder/`open`
#   $PREFIX/bin/hot-mic               launcher into the bundle's executable
mkdir -p "${PREFIX}/Applications" "${PREFIX}/bin" "${PREFIX}/Menu"
cp -R "${app}" "${PREFIX}/Applications/Hot Mic.app"
ln -s "../Applications/Hot Mic.app/Contents/MacOS/Hot Mic" "${PREFIX}/bin/hot-mic"

# menuinst entry so the app shows up in ~/Applications; the prefix itself is
# not indexed by Launchpad/Spotlight. Build the icon from the app icon set.
iconset="${build_dir}/hot-mic.iconset"
mkdir -p "${iconset}"
for size in 16 32 128 256 512; do
    cp "Dictation/Assets.xcassets/AppIcon.appiconset/HotMic_${size}.png" "${iconset}/icon_${size}x${size}.png"
    cp "Dictation/Assets.xcassets/AppIcon.appiconset/HotMic_${size}@2x.png" "${iconset}/icon_${size}x${size}@2x.png"
done
/usr/bin/iconutil -c icns "${iconset}" -o "${PREFIX}/Menu/hot-mic.icns"
cp "${RECIPE_DIR}/Menu/hot-mic.json" "${PREFIX}/Menu/hot-mic.json"
