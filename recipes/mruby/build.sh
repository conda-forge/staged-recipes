#!/bin/bash
set -exo pipefail

# Build using the 'full-core' gembox so additional standard mrbgems (including tools like mrbc) are included in the packaged build
# Create a local `MRUBY_CONFIG` by copying the default and switching the gembox to 'full-core'
cp build_config/default.rb build_config/conda.rb
sed -i.bak "s|conf.gembox 'default'|conf.gembox 'full-core'|" build_config/conda.rb
export MRUBY_CONFIG="build_config/conda.rb"

# Use compiler driver for linking `-Wl` options to work
export LD="${CC}"

rake all test

mkdir -p ${PREFIX}/{lib,bin,mrbgems,mrblib,include}
cp -r build/host/lib/*.a ${PREFIX}/lib
cp -r build/host/bin/* ${PREFIX}/bin
cp -r include build/host/{mrbgems,mrblib} ${PREFIX}
