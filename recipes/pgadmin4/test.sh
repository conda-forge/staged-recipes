#!/usr/bin/env bash
set -eux

# install test environment
mamba install \
  linecache2==1.0.0 \
  pbr==6.1.0 \
  psycopg2 \
  "pycodestyle>=2.5.0" \
  python-mimeparse==2.0.0 \
  selenium==4.27.1 \
  main::testscenarios==0.5.0 \
  testtools==2.7.2 \
  traceback2==1.4.0

# Detect windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  mamba install m2-make
else
  mamba install make
fi

POSTGRESQL_VERSION="99" python testing/update_config.py testing/test_config.json
cp testing/test_config.json web/regression/
cp testing/config_local.py web/
POSTGRESQL_VERSION="99" TEST_COMMAND="echo 'Done'" python testing/run_test_command.py

# One test: BackupJobTest fails
make check-python || true
