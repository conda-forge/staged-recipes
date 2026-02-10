#!/bin/bash
set -euxo pipefail

# Remember source directory (handle both conda-build and rattler-build)
if [ -n "${SRC_DIR}" ]; then
    SRC_ROOT="${SRC_DIR}"
else
    SRC_ROOT="$(pwd)"
fi

echo "=== Build environment ==="
echo "SRC_ROOT: ${SRC_ROOT}"
echo "PREFIX: ${PREFIX}"
echo "PWD: $(pwd)"
echo "Node version: $(node --version)"

# Navigate to source directory
cd "${SRC_ROOT}"

echo "=== Setting up pnpm via corepack ==="
# Enable corepack (bundled with Node.js 24+)
corepack enable
# Prepare specific pnpm version used by Podman Desktop
corepack prepare pnpm@10.20.0 --activate

# Verify pnpm is available
pnpm --version

echo "=== Configuring build environment ==="
# Set memory limit for Vite renderer build (requires 6GB)
export NODE_OPTIONS="--max-old-space-size=6144"

# Disable code signing (conda builds don't need app store signing)
export CSC_IDENTITY_AUTO_DISCOVERY=false

# Disable auto-update (not applicable for conda packages)
export PUBLISH_FOR_UPDATES=false

echo "=== Installing dependencies ==="
# Install all workspace dependencies
# --frozen-lockfile: Use exact versions from pnpm-lock.yaml
# --strict-peer-dependencies=false: conda's nodejs may not match exact semver ranges
pnpm install --frozen-lockfile --strict-peer-dependencies=false

echo "=== Building and packaging with electron-builder ==="
# Build in production mode, then package with electron-builder
# Use --dir to create unpacked directory only (skip platform-specific installers not needed for conda)
export MODE=production
pnpm build

# Detect platform and use appropriate electron-builder target
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Building for Linux..."
    pnpm electron-builder build --config .electron-builder.config.cjs --linux --dir --publish never --config.npmRebuild=false
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building for macOS..."
    pnpm electron-builder build --config .electron-builder.config.cjs --mac --dir --publish never --config.npmRebuild=false
else
    echo "ERROR: Unsupported platform: $OSTYPE"
    exit 1
fi

echo "=== Generating third-party license notices ==="
# Create combined license file for all npm dependencies
pnpm licenses generate-disclaimer --prod > ThirdPartyNotices.txt || {
    echo "WARNING: License generation had issues, creating placeholder"
    echo "Third-party licenses information" > ThirdPartyNotices.txt
}

# Verify license files exist
ls -la "${SRC_ROOT}/LICENSE"
ls -la "${SRC_ROOT}/ThirdPartyNotices.txt"

echo "=== Installing Podman Desktop to PREFIX ==="
# Install Electron app bundle (platform-specific)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: Install unpacked directory
    mkdir -p "${PREFIX}/lib/podman-desktop"
    cp -r dist/linux-unpacked/* "${PREFIX}/lib/podman-desktop/"

    echo "=== Creating launcher script ==="
    # Create wrapper script in bin/
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/podman-desktop" << 'EOF'
#!/bin/bash
# Podman Desktop launcher script
# Execute the Electron app from lib directory
exec "$(dirname "$0")/../lib/podman-desktop/podman-desktop" "$@"
EOF
    chmod +x "${PREFIX}/bin/podman-desktop"

    echo "=== Installing desktop integration files ==="
    # Install .desktop file for Linux application menu
    mkdir -p "${PREFIX}/share/applications"
    cat > "${PREFIX}/share/applications/podman-desktop.desktop" << 'EOF'
[Desktop Entry]
Name=Podman Desktop
Comment=Containers and Kubernetes for application developers
Exec=podman-desktop %U
Terminal=false
Type=Application
Icon=podman-desktop
Categories=Development;ContainerApplication;
Keywords=podman;docker;container;kubernetes;
StartupNotify=true
StartupWMClass=Podman Desktop
EOF

    # Install application icon
    mkdir -p "${PREFIX}/share/icons/hicolor/512x512/apps"
    if [ -f "buildResources/icon.png" ]; then
        cp "buildResources/icon.png" "${PREFIX}/share/icons/hicolor/512x512/apps/podman-desktop.png"
    elif [ -f "buildResources/512x512.png" ]; then
        cp "buildResources/512x512.png" "${PREFIX}/share/icons/hicolor/512x512/apps/podman-desktop.png"
    else
        echo "WARNING: Icon file not found in buildResources/"
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Install .app bundle
    mkdir -p "${PREFIX}/lib"
    if [ -d "dist/mac/Podman Desktop.app" ]; then
        cp -r "dist/mac/Podman Desktop.app" "${PREFIX}/lib/Podman Desktop.app"
    elif [ -d "dist/mac-arm64/Podman Desktop.app" ]; then
        cp -r "dist/mac-arm64/Podman Desktop.app" "${PREFIX}/lib/Podman Desktop.app"
    else
        echo "ERROR: macOS .app bundle not found in dist/"
        exit 1
    fi

    echo "=== Creating launcher script ==="
    # Create wrapper script in bin/
    mkdir -p "${PREFIX}/bin"
    cat > "${PREFIX}/bin/podman-desktop" << 'EOF'
#!/bin/bash
# Podman Desktop launcher script for macOS
# Execute the macOS .app bundle
exec "$(dirname "$0")/../lib/Podman Desktop.app/Contents/MacOS/Podman Desktop" "$@"
EOF
    chmod +x "${PREFIX}/bin/podman-desktop"
fi

echo "=== Build completed successfully! ==="
echo "Installed files:"
ls -la "${PREFIX}/bin/podman-desktop"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Application directory:"
    ls -la "${PREFIX}/lib/podman-desktop/" | head -20
    echo "Desktop file:"
    cat "${PREFIX}/share/applications/podman-desktop.desktop"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Application bundle:"
    ls -la "${PREFIX}/lib/Podman Desktop.app/"
    echo "Bundle contents:"
    ls -la "${PREFIX}/lib/Podman Desktop.app/Contents/" | head -20
fi
