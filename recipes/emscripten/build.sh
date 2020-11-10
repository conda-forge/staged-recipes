#!/bin/bash

export BINARYEN=$PREFIX

python tools/install.py $PREFIX/lib/emscripten-$PKG_VERSION/
# remove leftovers
rm $PREFIX/lib/emscripten-$PKG_VERSION/build_env_setup.sh
rm $PREFIX/lib/emscripten-$PKG_VERSION/conda_build.sh

python $RECIPE_DIR/link_bin.py

emcc

python $RECIPE_DIR/fix_emscripten_config.py

pushd $PREFIX/lib/emscripten-$PKG_VERSION/
npm install
popd

# We should probably not do this
# embuilder build ALL