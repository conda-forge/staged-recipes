#!/bin/bash

set -euo pipefail

# Make preinstall a no-op, we ship node as a tarball.
echo '#!/bin/bash' > scripts/preinstall.bash
yarn install
yarn build
cp ./lib/node/out/Release/node $PREFIX/bin/node-nbin
