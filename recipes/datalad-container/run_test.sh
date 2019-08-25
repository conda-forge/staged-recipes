#!/bin/bash

set -eu

# no network should be assumed
export DATALAD_TESTS_NONETWORK=1
export http_proxy=http://127.0.0.1:9/
export https_proxy=http://127.0.0.1:9/

if [ "$(uname)" = "Linux" ] || hash git-annex; then
    python -m nose -s -v datalad_container
fi
