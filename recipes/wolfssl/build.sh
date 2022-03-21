#!/bin/bash

set -ex

# enable unpriv user namespaces so bubblewrap and isolate the tests
sudo user.max_user_namespaces=15000

# the autoconf build has many more supported config options so we
# will continue to use it for unix and cmake only for windows for now

autoreconf --install

# configure command is shared with run_test.sh
bash -ex "$RECIPE_DIR"/config.sh

deathcat() {
    cat "$@"
    exit 1
}

make  -j "$CPU_COUNT"
make check || deathcat ./test-suite.log
make install

