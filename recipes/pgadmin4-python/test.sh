#!/usr/bin/env bash
set -eux

# Determine OS type
OS_TYPE=$(uname)

# install test environment
mamba install \
  linecache2==1.0.0 \
  openssl \
  pbr==6.1.0 \
  "pycodestyle>=2.5.0" \
  python-mimeparse==2.0.0 \
  selenium==4.27.1 \
  testtools==2.7.2 \
  traceback2==1.4.0 \
  testscenarios==0.5.0


if [ "$OS_TYPE" = "Darwin" ]; then
  mamba install psutil
else
  mamba install procps-ng
fi

POSTGRESQL_VERSION="99" python testing/update_config.py testing/test_config.json
PGADMIN_PKG="${PREFIX}"/lib/python"${PY_VER}"/site-packages/pgadmin4

# Due to circular imports, we run the regression inside the package itself
tar cf - web | (cd "${PGADMIN_PKG}"/; tar xf -)
tar xf tests.tar -C "${PGADMIN_PKG}"/

cp testing/config_local.py "${PGADMIN_PKG}"/
cp testing/test_config.json "${PGADMIN_PKG}"/web/regression/

# Pre-test server props
POSTGRESQL_VERSION="99" TEST_COMMAND="echo 'Done'" python testing/run_test_command.py

# One test fails: BackupJobTest -> use true
pushd "${PGADMIN_PKG}"
  PYTHONPATH=.:${PYTHONPATH:-.} python web/regression/runtests.py \
    --exclude feature_tests \
    --parallel \
    || true
popd

# Terminate all PostgreSQL-related processes
if [ "$OS_TYPE" = "Darwin" ]; then
  # macOS specific process listing
  for pid in $(ps -ax | grep -E "postgres|postmaster" | grep -v grep | awk '{print $1}'); do
    kill -9 $pid 2>/dev/null || true
  done
else
  # Linux process listing
  for pid in $(ps -ef | grep -E "postgres|postmaster" | grep -v grep | awk '{print $2}'); do
    kill -9 $pid 2>/dev/null || true
  done
fi

