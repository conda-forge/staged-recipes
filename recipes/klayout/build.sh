#!/bin/bash
"${SRC_DIR}/build.sh"
echo "bin-release Contents"
echo "--------------------"
ls bin-release
echo "--------------------"
cp bin-release/klayout "${PREFIX}/bin"
