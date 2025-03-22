#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd ${SRC_DIR}/tools/dts2repl
  cp LICENSE ${SRC_DIR}/dts2repl-LICENSE
  ${PYTHON} -m pip install . --no-deps --no-build-isolation -vv
popd

# Install non-pip Python tools
mkdir -p ${PREFIX}/share/renode-python-tools/
cp -r ${SRC_DIR}/tools/{csv2resd,execution_tracer,gdb_compare,guest_cache,metrics_analyzer} ${PREFIX}/share/renode-python-tools/

exit 0