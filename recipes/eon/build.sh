#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

tee native.ini << EOF
[binaries]
python = '${PREFIX}/bin/python'
EOF

meson -Dpython.install_env=prefix \
    --native-file native.ini \
    -Dwith_metatomic=True \
    -Dpip_metatomic=False \
    -Dtorch_path=${PREFIX} \
    ${MESON_ARGS} build
meson compile -C build -v
meson install -C build
