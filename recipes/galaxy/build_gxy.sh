set -euxo pipefail

${PYTHON} -m pip install ./$PKG_NAME/ --no-deps --no-build-isolation -vv
