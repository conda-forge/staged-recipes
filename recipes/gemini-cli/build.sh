#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to skip unnecessary prepare step and remove workspace references
mv package.json package.json.bak
jq "del(.scripts.prepare) | del(.workspaces)" < package.json.bak > package.json

# Create package archive and install globally
PKG_VERSION=$(jq -r .version package.json)
PKG_NAME=$(jq -r .name package.json | sed 's|@||;s|/|-|g')
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --prefix="${PREFIX}" \
    --build-from-source \
    "./${PKG_NAME}-${PKG_VERSION}.tgz"

# Convert symlinks to wrapper scripts for Windows compatibility
if [ -L "${PREFIX}/bin/gemini" ]; then
    # Get the target of the symlink
    SYMLINK_TARGET=$(readlink "${PREFIX}/bin/gemini")
    rm "${PREFIX}/bin/gemini"
    
    # Create a proper Node.js wrapper script instead of symlink
    cat > "${PREFIX}/bin/gemini" << 'EOF'
#!/usr/bin/env node
// Cross-platform wrapper script for gemini-cli
const path = require('path');
const modulePath = path.join(__dirname, '..', 'lib', 'node_modules', '@google', 'gemini-cli', 'dist', 'index.js');

// Import the ES module
import(modulePath).catch((error) => {
    console.error('Failed to start gemini-cli:', error.message);
    process.exit(1);
});
EOF
    chmod +x "${PREFIX}/bin/gemini"
fi

# Remove all symlinks in node_modules/.bin directories for Windows compatibility
find "${PREFIX}/lib/node_modules" -name ".bin" -type d | while read bin_dir; do
    if [ -d "$bin_dir" ]; then
        echo "Processing bin directory: $bin_dir"
        find "$bin_dir" -type l | while read symlink; do
            if [ -L "$symlink" ]; then
                # Get the target of the symlink
                target=$(readlink "$symlink")
                echo "Replacing symlink $symlink -> $target"
                rm "$symlink"
                
                # Create a script that executes the target
                cat > "$symlink" << EOF
#!/usr/bin/env node
// Auto-generated script to replace symlink for Windows compatibility
const path = require('path');
const { spawn } = require('child_process');

// Resolve the target relative to this script's directory
const scriptDir = __dirname;
const targetPath = path.resolve(scriptDir, '$target');

// Execute the target with the same arguments
const child = spawn('node', [targetPath, ...process.argv.slice(2)], {
    stdio: 'inherit',
    cwd: process.cwd()
});

child.on('exit', (code) => {
    process.exit(code || 0);
});
EOF
                chmod +x "$symlink"
            fi
        done
    fi
done

# Create license report for dependencies  
# Only run pnpm if we have a proper package.json without workspace issues
if [ -f package.json ]; then
    # Remove any workspace references that might cause issues
    jq "del(.workspaces) | del(.devDependencies) | del(.scripts)" package.json > package.json.tmp
    mv package.json.tmp package.json
    
    # Try to install and generate licenses, but don't fail if it doesn't work
    pnpm install --prod --ignore-scripts || echo "Warning: pnpm install failed, skipping license generation"
    pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || echo "Warning: license generation failed"
fi
