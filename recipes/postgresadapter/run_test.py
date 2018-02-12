import subprocess
import postgresadapter
import os
import time
import atexit
import sys
import shlex
from postgresadapter.tests import setup_postgresql_data



def start_postgres():
    """Bring up a container running PostgreSQL with PostGIS. Pipe the output of
    the container process to stdout, until the database is ready to accept
    connections. This container may be stopped with ``stop_postgres()``.

    Returns the local port as a string.
    """
    print('Starting PostgreSQL server...')

    # More options here: https://github.com/appropriate/docker-postgis
    cmd = shlex.split('docker run --rm --name pgadapter-postgres --publish 5432 '
                      'mdillon/postgis:9.4-alpine')
    proc = subprocess.Popen(cmd,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            universal_newlines=True)

    # The database may have been restarted in the container, so track whether
    # initialization happened or not.
    pg_init = False
    while True:
        output_line = proc.stdout.readline()
        print(output_line.rstrip())
        # If the process exited, raise exception.
        if proc.poll() is not None:
            raise Exception('PostgreSQL server failed to start up properly.')
        # Detect when initialization has happened, so we can stop waiting when
        # the database is accepting connections.
        if ('PostgreSQL init process complete; '
                'ready for start up') in output_line:
            pg_init = True
        elif (pg_init and
              'database system is ready to accept connections' in output_line):
            break

    # Print the local port to which Docker mapped Postgres
    cmd = shlex.split('docker ps --filter "name=pgadapter-postgres" --format '
                      '"{{ .Ports }}"')
    port_map = subprocess.check_output(cmd, universal_newlines=True).strip()
    port = port_map.split('->', 1)[0].split(':', 1)[1]
    return port


def stop_postgres(let_fail=False):
    """Attempt to shut down the container started by ``start_postgres()``.
    Raise an exception if this operation fails, unless ``let_fail``
    evaluates to True.
    """
    try:
        print('Stopping PostgreSQL server...')
        subprocess.check_call('docker ps -q --filter "name=pgadapter-postgres" | '
                              'xargs docker rm -vf', shell=True)
    except subprocess.CalledProcessError:
        if not let_fail:
            raise


### Start PostgreSQL
stop_postgres(let_fail=True)
local_port = start_postgres()
atexit.register(stop_postgres)

### Run PostgresAdapter tests
setup_postgresql_data.main(port=local_port)
assert postgresadapter.test(port=local_port)

### Run PostGIS tests
assert postgresadapter.test_postgis(port=local_port)

# Print the version
print('postgresadapter.__version__: %s' % postgresadapter.__version__)

sys.exit(0)
