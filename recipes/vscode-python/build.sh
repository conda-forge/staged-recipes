#!/bin/bash

set -exuo pipefail

export

# This bundles Python packages but this is noted in ThirdPartyVersions.txt
# The package does some trickery to use these packages explicitly and not the ones installed in the environment.
# It would be nice to unbundle them but the process isn't straight-forward.
PIP_NO_INDEX=False python -m pip --disable-pip-version-check install -t ./pythonFiles/lib/python --no-cache-dir --implementation py --no-deps --upgrade -r requirements.txt -vvv
python ./pythonFiles/install_debugpy.py
npm ci --prefer-offline
npm run addExtensionDependencies
npm run package
code-server --install-extension ms-python-insiders.vsix
