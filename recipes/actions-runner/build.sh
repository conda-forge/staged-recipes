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

cmd=$1
shift

cd "$CONDA_PREFIX/lib/actions-runner"

if [[ "$cmd" == "config" ]]; then
  source ./env.sh
  shopt -s nocasematch
  if [[ "$1" == "remove" ]]; then
      ./bin/Runner.Listener "$@"
  else
      ./bin/Runner.Listener configure "$@"
  fi
elif [[ "$cmd" == "run" ]]; then
  exec ./run.sh "$@"
else
  echo "Unknown command ${cmd}!"
  exit 1
fi
EOF

chmod +x "$PREFIX/bin/actions-runner"
