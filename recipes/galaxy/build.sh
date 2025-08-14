set -euxo pipefail

${PYTHON} -m pip install --no-deps --no-build-isolation -vv ./$PKG_NAME/ 
