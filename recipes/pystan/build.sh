#!/bin/bash
set -ex

STAN_VER=${PKG_VERSION:0:${#PKG_VERSION}-2}
INSTALL_LOG=install.log

# These folders are not needed in the build and we don't want to include them
# in the package. This should be cleaned via MANIFEST.in.
pushd pystan/stan/lib/stan_math_${STAN_VER}
rm -fr doc doxygen make test lib/cpplist_* lib/gtest_*
popd

# Log everything to a file to avoid reaching max output limit in travis.
touch $INSTALL_LOG

function dump_output() {
  let N=${1:-"10"}
  echo "Tailing the last $N lines of output"
  tail -${N} $INSTALL_LOG
}

function error_handler() {
  echo "ERROR: An error was encountered in the build"
  dump_output 500
  exit 1
}

trap 'error_handler' ERR

bash -c "while true; do echo === \$(date) === building ...; sleep 60; done" &
PING_LOOP_PID=$!

python setup.py install -q --single-version-externally-managed --record=record.txt \
  >> $INSTALL_LOG 2>&1

# Build finished OK
dump_output

kill $PING_LOOP_PID
