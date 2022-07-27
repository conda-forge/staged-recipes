#!/bin/bash

set -eoux pipefail

cd ./src
# Ignore git commands since we're building from a sdist
sed -i 's|^.*Exec Command="git update-index.*$||g' ./dir.proj

dotnet msbuild -t:Build -p:PackageRuntime="linux-x64" -p:BUILDCONFIG="Release" -p:RunnerVersion="$PKG_VERSION" ./dir.proj

cd ..
# copy extra files
cp -R ./src/Misc/layoutroot/* ./_layout/
rm -f ./_layout/*.cmd
cp -R ./src/Misc/layoutbin/* ./_layout/bin/

cp -R ./_layout $PREFIX/lib/actions-runner

# Add actions-runner script
tee "$PREFIX/bin/actions-runner" > /dev/null << 'EOF'
#!/bin/bash

set -e

script=$1

cd "$CONDA_PREFIX/lib/actions-runner"
shift
exec "./${script}.sh" "$@"
EOF

chmod +x "$PREFIX/bin/actions-runner"
