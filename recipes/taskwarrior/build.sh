#!/bin/bash

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cmake -S . -B build \
    ${CMAKE_ARGS} \
  -DSYSTEM_CORROSION=ON
cmake --build build --parallel ${CPU_COUNT}
ctest -V --test-dir build
cmake --install build

# Install shell completions
# (fish and zsh are already installed by `cmake --install` to the correct paths)
install -d "${PREFIX}/share/bash-completion/completions"
install "scripts/bash/task.sh" "${PREFIX}/share/bash-completion/completions/task"
