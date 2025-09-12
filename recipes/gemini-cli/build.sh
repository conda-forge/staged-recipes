#!/bin/bash
set -euo pipefail

# Build the project
npm ci
npm run build

# Create directories
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib/node_modules/${PKG_NAME}"

# Copy the bundled executable
cp bundle/gemini.js "${PREFIX}/lib/node_modules/${PKG_NAME}/"

# Create the executable wrapper
cat <<EOF > "${PREFIX}/bin/gemini"
#!/bin/bash
node "${PREFIX}/lib/node_modules/${PKG_NAME}/gemini.js" "\$@"
EOF

# Make it executable
chmod +x "${PREFIX}/bin/gemini"
