#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/share
cp -R sagemaker-code-editor $PREFIX/share/

mkdir -p ${PREFIX}/bin
cat <<'EOF' >${PREFIX}/bin/sagemaker-code-editor
#!/bin/bash

PREFIX_DIR=$(dirname ${BASH_SOURCE})

# Make PREDIX_DIR absolute
if [[ $(uname) == 'Linux' ]]; then
  PREFIX_DIR=$(readlink -f ${PREFIX_DIR})
else
  pushd ${PREFIX_DIR}
  PREFIX_DIR=$(pwd -P)
  popd
fi

# Go one level up
PREFIX_DIR=$(dirname ${PREFIX_DIR})
${PREFIX_DIR}/share/sagemaker-code-editor/bin/code-server-oss "$@"
EOF

chmod +x ${PREFIX}/bin/sagemaker-code-editor

if [[ "${build_platform}" == "${target_platform}" ]]; then
  # Directly check whether the sagemaker-code-editor call also works inside of conda-build
  sagemaker-code-editor --help
fi