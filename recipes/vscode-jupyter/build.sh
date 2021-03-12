#!/bin/bash

set -exuo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  export CXXFLAGS=${CXXFLAGS/c++14/c++17}
fi

# This bundles Python packages but this is noted in ThirdPartyVersions.txt
# The package does some trickery to use these packages explicitly and not the ones installed in the environment.
# It would be nice to unbundle them but the process isn't straight-forward.
PIP_NO_INDEX=False python -m pip  --use-deprecated=legacy-resolver --disable-pip-version-check install -t ./pythonFiles/lib/python --no-cache-dir --implementation py --no-deps --upgrade -r ./requirements.txt
export ZEROMQ_VERSION=$(jq -r '.dependencies["zeromq"]' package.json)
npm install "zeromq@${ZEROMQ_VERSION/^}" --zmq-shared --build-from-source
npm install
find . -name zeromq.node
rm -r node_modules/zeromq/prebuilds
find . -name zeromq.node
npm run package
code-server --install-extension ms-toolsai-jupyter-insiders.vsix
find ${PREFIX}/share/code-server/extensions/ms-toolsai.jupyter-*/out -name '*.js.map' -delete
