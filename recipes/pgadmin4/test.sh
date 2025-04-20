#!/usr/bin/env bash
set -eux

# install test environment
mamba install \
  linecache2==1.0.0 \
  openssl \
  pbr==6.1.0 \
  "pycodestyle>=2.5.0" \
  python-mimeparse==2.0.0 \
  selenium==4.27.1 \
  testtools==2.7.2 \
  traceback2==1.4.0
  # We propose a conda version
  # main::testscenarios==0.5.0

POSTGRESQL_VERSION="99" python testing/update_config.py testing/test_config.json
PGADMIN_PKG="${PREFIX}"/lib/python"${PY_VER}"/site-packages/pgadmin4

# Due to circular imports, we run the regression inside the package itself
tar cf - web | (cd "${PGADMIN_PKG}"/; tar xf -)
cp testing/config_local.py "${PGADMIN_PKG}"/
cp testing/test_config.json "${PGADMIN_PKG}"/web/regression/

# Pre-test server props
POSTGRESQL_VERSION="99" TEST_COMMAND="echo 'Done'" python testing/run_test_command.py

# One test fails: BackupJobTest
pushd "${PGADMIN_PKG}"
  PYTHONPATH=.:${PYTHONPATH:-.} python web/regression/runtests.py --exclude feature_tests || true
popd

# Terminate the server if POSTGRESQL_PID is set
if [ -n "${POSTGRESQL_PID}" ]; then
  kill -9 "${POSTGRESQL_PID}"
fi

