import os
import shutil
import subprocess
import sys
import time
import psycopg2

def create_databases(db_names, pg_version):
    port = f"59{pg_version}"
    for db_name in db_names:
        try:
            with psycopg2.connect(f"dbname=postgres user=postgres host=localhost port={port}") as conn:
                conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT) # Enable autocommit
                with conn.cursor() as cur:
                    cur.execute(f"CREATE DATABASE {db_name};")
                    print(f"Database '{db_name}' created successfully.", file=sys.stderr)
        except psycopg2.Error as e:
            print(f"Error creating database '{db_name}': {e}", file=sys.stderr)
            sys.exit(1)


def setup_postgresql(pg_version, conda_prefix):
    pg_dir = f".postgresql/{pg_version}-main"
    pg_stat_tmp = f"{pg_dir}.pg_stat_tmp"
    pg_hba_conf = f"{pg_dir}/pg_hba.conf"
    pg_conf = f"{pg_dir}/postgresql.conf"
    port = f"59{pg_version}"

    os.makedirs(pg_dir, exist_ok=True)
    os.makedirs(pg_stat_tmp, exist_ok=True)

    subprocess.run(["initdb", "-D", pg_dir, "-U", "postgres", "--auth=trust", "--no-instructions", "--no-locale", "-E", "UTF8"], check=True)

    # Create tablespace directory
    tablespace_path = os.path.join(pg_dir, "tablespaces")
    os.makedirs(tablespace_path, exist_ok=True)

    with open(pg_hba_conf, "w") as f:
        f.write("local   all  all                    trust\n")
        f.write("host    all  all      127.0.0.1/32  trust\n")
        f.write("host    all  all      ::1/128       trust\n")

    with open(pg_conf, "r") as f:
        config_lines = f.readlines()

    with open(pg_conf, "w") as f:
        for line in config_lines:
            if line.startswith("port =") or line.startswith("#port ="):
                f.write(f"port = {port}\n")
            else:
                f.write(line)

    postgres_proc = subprocess.Popen(
        [f"{conda_prefix}/bin/postgres", "-D", pg_dir, "-c", f"config_file={pg_conf}"],
        stdout=subprocess.PIPE,  # Capture stdout
        stderr=subprocess.PIPE,  # Capture stderr
        text=True  # Convert output to text
    )
    time.sleep(5)

    try:
        # Use -q to suppress unnecessary output from pg_isready
        result = subprocess.run([f"{conda_prefix}/bin/pg_isready", "-q", "-h", "localhost", "-p", port], capture_output=True, text=True, check=True)
        print(result.stdout, file=sys.stderr) # Print pg_isready output if successful
    except subprocess.CalledProcessError as e:
        print(f"pg_isready failed: {e}", file=sys.stderr)
        # Print PostgreSQL logs for debugging
        print("PostgreSQL logs:", file=sys.stderr)
        print(postgres_proc.stdout.read(), file=sys.stderr)
        print(postgres_proc.stderr.read(), file=sys.stderr)

        # Kill the postgres process to prevent it from hanging
        postgres_proc.kill()
        postgres_proc.wait() # Wait for the process to terminate

        raise  # Re-raise the exception to stop the script

    # subprocess.run(["psql", "-U", "postgres", "-p", port, "-h", "localhost", "-c", "CREATE EXTENSION pgagent;"], check=True)
    # subprocess.run(["psql", "-U", "postgres", "-p", port, "-h", "localhost", "-c", "CREATE EXTENSION pldbgapi;"], check=True)
    # Create test databases *AFTER* PostgreSQL starts
    # test_databases = ["erdtestdb_be12acd", "erdtestdb_92d42a5", "erdtestdb_0a028eb"]
    # create_databases(test_databases, pg_version)

    return postgres_proc

def run_tests(test_command, conda_prefix):
    try:
        # Execute the provided test command
        completed_process = subprocess.run(test_command, shell=True, check=True, executable='/bin/bash', env={**os.environ, "CONDA_PREFIX": conda_prefix})
        return completed_process.returncode # Return the exit code

    except subprocess.CalledProcessError as e:
        print(f"Error running tests: {e}", file=sys.stderr)
        return e.returncode  # Return the non-zero exit code from the failed command
    except Exception as e:
        print(f"Error during testing: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    pg_version = os.environ.get("POSTGRESQL_VERSION")  # Get version from environment variable
    conda_prefix = os.environ.get("CONDA_PREFIX")
    test_command = os.environ.get("TEST_COMMAND", "make check-python") # Get test command from environment variable, defaulting to "make check-python"

    try:
        postgres_proc = setup_postgresql(pg_version, conda_prefix)
        os.environ["POSTGRES_PID"] = str(postgres_proc.pid)

        exit_code = run_tests(test_command, conda_prefix) # Run tests and capture exit code
        sys.exit(exit_code) # Exit with the test command's exit code

    except Exception as e:
        print(f"Error during setup or testing: {e}", file=sys.stderr)
        sys.exit(1)
    # finally:
    #     if "POSTGRES_PID" in os.environ:
    #         try:
    #             postgres_pid = int(os.environ["POSTGRES_PID"])
    #             subprocess.run(["kill", str(postgres_pid)], check=False) # Kill the process
    #             print("PostgreSQL server terminated.", file=sys.stderr)
    #         except Exception as e:
    #             print(f"Error terminating PostgreSQL: {e}", file=sys.stderr)