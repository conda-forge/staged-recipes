# Build script for nextcloud-client, referenced from recipe.yaml via
# `build: script: file:`. Runs with the build and host prefixes activated;
# ${CMAKE_ARGS} is set by rattler-build to the platform/compiler flags.
set -eu

cmake -B build -G Ninja \
    ${CMAKE_ARGS:-} \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHELL_INTEGRATION=OFF \
    -DBUILD_SHELL_INTEGRATION_ICONS=OFF
cmake --build build
cmake --install build

# macOS only (detected via the bundle, which only exists there): CMake
# builds the GUI as nextcloud.app at the prefix root, because
# KDECMakeSettings sets CMAKE_MACOSX_BUNDLE (KDE's "GUI executables by
# default"). The bundle is intentional (see NOTES.md); move it to
# $PREFIX/Applications like the herdr-app recipe does, point its
# Info.plist at the icns the build placed in Contents/Resources (CMake's
# default plist has no icon entry), and leave a shim in bin/ so
# `nextcloud` keeps working from PATH.
if [ -d "${PREFIX}/nextcloud.app" ]; then
    app="${PREFIX}/Applications/Nextcloud.app"
    mkdir -p "${PREFIX}/Applications"
    mv "${PREFIX}/nextcloud.app" "${app}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string Nextcloud-macOS" "${app}/Contents/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile Nextcloud-macOS" "${app}/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :CFBundleName string Nextcloud" "${app}/Contents/Info.plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Set :CFBundleName Nextcloud" "${app}/Contents/Info.plist"
    printf '#!/bin/sh\nexec "$(dirname "$0")/../Applications/Nextcloud.app/Contents/MacOS/nextcloud" "$@"\n' > "${PREFIX}/bin/nextcloud"
    chmod 755 "${PREFIX}/bin/nextcloud"
fi
