#!/bin/bash
set -euo pipefail

case "${target_platform}" in
  linux-64) rid="linux-x64" ;;
  linux-aarch64) rid="linux-arm64" ;;
  osx-64) rid="osx-x64" ;;
  osx-arm64) rid="osx-arm64" ;;
  *)
    echo "Unsupported target_platform: ${target_platform}" >&2
    exit 1
    ;;
esac

dotnet publish tools/cli/Cascode.Cli.csproj \
  -c Release \
  -r "${rid}" \
  -p:SelfContained=false \
  -p:PublishTrimmed=false \
  -o build/out

# Install application files to lib/cascode
mkdir -p "${PREFIX}/lib/cascode"
cp -r build/out/* "${PREFIX}/lib/cascode/"

# Create wrapper script in bin
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/cascode" << 'EOF'
#!/bin/bash
exec "$(dirname "$0")/../lib/cascode/Cascode.Cli" "$@"
EOF
chmod +x "${PREFIX}/bin/cascode"
