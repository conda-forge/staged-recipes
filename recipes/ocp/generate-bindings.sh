#!/bin/sh

set -euo pipefail

PLATFORM=$(uname)

declare -a EXTRA_INCLUDES

if [[ ${PLATFORM} = 'Darwin' ]]; then
  CLANGLIB=${PREFIX}/lib/libclang.dylib
  EXTRA_INCLUDES+=(-i ${PREFIX}/include/c++/v1/)
elif [[ ${PLATFORM} = 'Linux' ]]; then
  CLANGLIB=${PREFIX}/lib/libclang.so
fi

export PYTHONPATH=${SRC_DIR}/pywrap/
${PYTHON} -m bindgen -n ${CPU_COUNT} \
	-i ${PREFIX}/include/ \
	-i ${PREFIX}/include/vtk-9.0/ \
	-i ${PREFIX}/include/c++/v1/ \
	-i ${PREFIX}/lib/clang/10.0.1/include/ \
	"${EXTRA_INCLUDES[@]}" \
	-l ${CLANGLIB} \
	-v parse ocp.toml out.pkl
${PYTHON} -m bindgen -n ${CPU_COUNT} -v transform ocp.toml out.pkl out_f.pkl
${PYTHON} -m bindgen -n ${CPU_COUNT} -v generate ocp.toml out_f.pkl

# copy files into src
mkdir -p ${PREFIX}/src/
cp -r OCP ${PREFIX}/src/

# copy header files into include
mkdir -p ${PREFIX}/include/OCP
cp -r OCP/*.h* ${PREFIX}/include/OCP
