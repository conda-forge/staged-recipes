#!/bin/bash
"${SRC_DIR}"/build.sh -python ${PYTHON} -bin "${PREFIX}/bin"
echo "bin Contents"
echo "--------------------"
ls "${PREFIX}/bin"
