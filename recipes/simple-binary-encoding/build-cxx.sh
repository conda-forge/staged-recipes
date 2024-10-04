#!/bin/bash

set -xeo pipefail

mkdir build
cd build

cmake \
  -LAH \
  ${CMAKE_ARGS} \
  ..

cmake --build . --clean-first

ctest -C Release

install -m 775 -d ${PREFIX}/include/otf/uk_co_real_logic_sbe_ir_generated
install -m 664 ${SRC_DIR}/sbe-tool/src/main/cpp/otf/*.h ${PREFIX}/include/otf
install -m 664 ${SRC_DIR}/sbe-tool/src/main/cpp/uk_co_real_logic_sbe_ir_generated/*.h ${PREFIX}/include/otf/uk_co_real_logic_sbe_ir_generated
