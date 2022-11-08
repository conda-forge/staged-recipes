#!/bin/bash

set -euxo pipefail

if [[ "${target_plarform}" == osx-* ]]; then
	./configure-mac_os_x.sh --default --install-dir $PREFIX
else
	./configure-linux.sh --default --install-dir $PREFIX
fi

make -j${CPU_COUNT} libs
make install
