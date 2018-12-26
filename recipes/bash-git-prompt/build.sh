#!/bin/bash

set -o xtrace -o nounset -o pipefail -o errexit

# See https://github.com/magicmonty/bash-git-prompt/blob/master/bash-git-prompt.rb

mkdir -p "${PREFIX}/share/bash-git-prompt"

install \
  gitprompt.sh \
  gitprompt.fish \
  git-prompt-help.sh \
  gitstatus.py \
  gitstatus.sh \
  gitstatus_pre-1.7.10.sh \
  prompt-colors.sh \
  "${PREFIX}/share/bash-git-prompt/"

mkdir -p "${PREFIX}/share/bash-git-prompt/themes"
cp themes/*.bgptheme themes/Custom.bgptemplate "${PREFIX}/share/bash-git-prompt/themes/"

mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate-${PKG_NAME}.sh" "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh"
