#!/bin/sh

set -e

mkdir test
echo '#!/bin/sh' > test/entrypoint.sh
chmod +x test/entrypoint.sh

makeself test test.run test ./entrypoint.sh
./test.run
