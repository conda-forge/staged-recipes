#!/bin/bash

set -eoux pipefail

tree
pushd ./src
dotnet msbuild -t:Build -p:PackageRuntime="linux-x64" -p:BUILDCONFIG="Release" -p:RunnerVersion="2.294.0" ./dir.proj
popd
cp -R ./src/Misc/layoutroot/* ./_layout/
rm -f ./_layout/*.cmd
cp -R ./src/Misc/layoutbin/* ./_layout/bin/

cp -R ./_layout $PREFIX/actions-runner
