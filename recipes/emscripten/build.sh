#!/bin/bash

# Move source to the PREFIX
mv "${SRC_DIR}" "${PREFIX}/emscripten"
cd "${PREFIX}/emscripten"

# Write the config file
cat >${PREFIX}/emscripten/config <<EOF
BINARYEN_ROOT = "${PREFIX}/bin"

EMSCRIPTEN_ROOT = "${PREFIX}/emscripten"

LLVM_ROOT = "${PREFIX}/bin"

JAVA = "${PREFIX}/bin/java"

NODE_JS = "${PREFIX}/bin/node"
COMPILER_ENGINE = NODE_JS
JS_ENGINES = [NODE_JS]

TEMP_DIR = "${PREFIX}/emscripten/tmp"
EOF

# Write activate and deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh <<EOF
export EM_CONFIG="${PREFIX}/emscripten/config"
export EM_CACHE="${PREFIX}/emscripten/cache"
export EMCC_WASM_BACKEND=1
EOF
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh <<EOF
unset EM_CONFIG
unset EM_CACHE
unset EMCC_WASM_BACKEND
EOF

# Run activate script
source "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"

# Configure build chain
export CC="${PREFIX}/bin/clang"
export CXX="${PREFIX}/bin/clang++"
export LD="${PREFIX}/bin/lld"

# Prebuild some packages with Emscripten
mkdir -p "${PREFIX}/emscripten/cache"
mkdir -p "${PREFIX}/emscripten/tmp"
${PYTHON} embuilder.py build       \
	                      libc \

# Add symlinks to `bin` for executables
ln -s ${PREFIX}/emscripten/em++ ${PREFIX}/bin/em++

# Run deactivate script
source "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
