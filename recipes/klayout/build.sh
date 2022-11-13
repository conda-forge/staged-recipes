#!/bin/bash
"${SRC_DIR}"/build.sh -debug -python ${PYTHON} 
echo "bin-release Contents"
echo "--------------------"
ls bin-release
echo "--------------------"
cp bin-release/klayout "${PREFIX}/bin" -pylib ""
