#!/bin/bash

cmake -S . -B build ${CMAKE_ARGS}

cmake --build build --parallel ${CPU_COUNT}
cmake --install build

# Install shell completions
install -d "${PREFIX}/share/bash-completion/completions"
install "completion/timew-completion.bash" "${PREFIX}/share/bash-completion/completions/timew"
install -d "${PREFIX}/share/zsh/site-functions"
install "completion/timew.zsh" "${PREFIX}/share/zsh/site-functions/_timew"
install -d "${PREFIX}/share/fish/vendor_completions.d"
install "completion/timew.fish" "${PREFIX}/share/fish/vendor_completions.d/timew.fish"
