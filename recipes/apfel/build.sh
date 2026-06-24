#!/bin/bash
set -euo pipefail

# apfel is pure SwiftPM (no .xcodeproj) — the Swift toolchain is
# system-provided by Xcode/Command Line Tools on the conda-forge osx_arm64
# runner; there is no conda-forge Swift compiler package to depend on.
# FoundationModels' tokenCount/contextSize symbols only exist in the macOS
# 26.4 SDK, and apfel's sources call them unconditionally (no @available
# guard), so whichever toolchain we build with must resolve to that SDK or
# newer, or the build fails with "value of type 'SystemLanguageModel' has
# no member 'tokenCount'". The active toolchain is usually enough, but if
# the runner ships multiple Xcodes (as conda-forge's does, per the ghostty
# feedstock) and the default one is older, scan for a newer one.
required_major=26
required_minor=4

sdk_ok() {
    local major="${1%%.*}"
    local minor="${1#*.}"
    [[ "$minor" == "$1" ]] && minor=0
    (( major > required_major )) || { (( major == required_major )) && (( minor >= required_minor )); }
}

current_sdk="$(xcrun --show-sdk-version 2>/dev/null || true)"
if [[ -n "${current_sdk}" ]] && sdk_ok "${current_sdk}"; then
    echo "==> Using active toolchain (SDK ${current_sdk})"
else
    echo "==> Active SDK (${current_sdk:-none}) is older than ${required_major}.${required_minor}; scanning for a newer Xcode..."
    best_dev_dir=""
    best_sdk=""
    for xc in /Applications/Xcode*.app; do
        [[ -e "${xc}" ]] || continue
        dev_dir="${xc}/Contents/Developer"
        sdk="$(DEVELOPER_DIR="${dev_dir}" xcrun --show-sdk-version 2>/dev/null || true)"
        [[ -n "${sdk}" ]] || continue
        sdk_ok "${sdk}" || continue
        if [[ -z "${best_sdk}" ]] || [[ "$(printf '%s\n%s\n' "${sdk}" "${best_sdk}" | sort -V | tail -1)" == "${sdk}" ]]; then
            best_dev_dir="${dev_dir}"
            best_sdk="${sdk}"
        fi
    done
    if [[ -z "${best_dev_dir}" ]]; then
        echo "error: no Xcode/Command Line Tools with the macOS ${required_major}.${required_minor}+ SDK found." >&2
        echo "       apfel requires the macOS 26.4 SDK for FoundationModels tokenCount/contextSize." >&2
        exit 1
    fi
    export DEVELOPER_DIR="${best_dev_dir}"
    echo "==> Selected ${DEVELOPER_DIR} (SDK ${best_sdk})"
fi

# Builds the release binary and the man page (man/apfel.1.in -> .build/release/apfel.1).
make build

# The upstream release tarball's demo/ sometimes carries AppleDouble (._*)
# files from macOS xattr/pax headers; strip defensively before installing.
find . -name '._*' -delete

install -d "${PREFIX}/bin"
install -m 755 .build/release/apfel "${PREFIX}/bin/apfel"

install -d "${PREFIX}/share/man/man1"
install -m 644 .build/release/apfel.1 "${PREFIX}/share/man/man1/apfel.1"

install -d "${PREFIX}/share/apfel/demo"
cp -r demo/. "${PREFIX}/share/apfel/demo/"
