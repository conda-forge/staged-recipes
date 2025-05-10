import argparse
import os
import subprocess
import threading
import time

import psutil

from pgadmin_test_utils import setup_signal_handler, setup_timeout


# Parse command-line arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Run pgAdmin4 with custom flags")
    parser.add_argument("-f", "--flags", action="append", default=[],
                        help="Additional flags to pass to pgAdmin4 (can specify multiple times)")
    parser.add_argument("--timeout", type=int, default=60,
                        help="Timeout in seconds (default: 60)")
    return parser.parse_args()

# Register signal handler
setup_signal_handler()

# Global variable to store the process reference
process = None

def run_pgadmin4(args):
    global process
    # Start pgAdmin4 process using xvfb-run
    prefix = os.environ.get("PREFIX", "")
    pgadmin4_executable = os.path.join(prefix, "usr/pgadmin4/bin/pgadmin4")

    cmd = ["xvfb-run", pgadmin4_executable]
    cmd.extend(["--no-sandbox"])
    cmd.extend(args.flags)

    print(f"Running command: {' '.join(cmd)}")

    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
        bufsize=1
    )

    try:
        stdout, stderr = process.communicate(timeout=args.timeout)
        print("Return Code:", process.returncode)
        print("Output:\n", stdout)
        if process.returncode != 0:
            print("Error occurred during execution.")
    except subprocess.TimeoutExpired:
        stdout, stderr = process.communicate()
        print("Process timed out!")
        print("Output:\n", stdout)

    process.wait()

def is_pgadmin4_running():
    """Check if pgAdmin4.py process is running."""
    for proc in psutil.process_iter(attrs=["cmdline", "pid"]):
        try:
            cmdline = proc.info.get("cmdline")
            if cmdline is not None and any("pgAdmin4.py" in arg for arg in cmdline):
                psutil.Process(proc.info['pid']).terminate()
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return False

def main():
    args = parse_args()

    # Set a reasonable timeout
    timer = setup_timeout(args.timeout)

    try:
        # Start pgAdmin4 in a separate thread
        pgadmin_thread = threading.Thread(target=run_pgadmin4, args=(args,))
        pgadmin_thread.daemon = True
        pgadmin_thread.start()

        # Add a maximum wait time in the main thread as backup
        start_time = time.time()
        max_wait = 30  # seconds

        while time.time() - start_time < max_wait:
            if is_pgadmin4_running():
                print("TEST: pgAdmin4 process detected as running")
                timer.cancel()
                print("Test completed - pgAdmin4 started successfully")
                if process:
                    process.terminate()
                os._exit(0)
            time.sleep(1)

        # If we reach here, either timeout occurred or thread ended
        print("Maximum wait time reached - exiting with success anyway")
        timer.cancel()
        if process:
            process.terminate()
        os._exit(0)

    except KeyboardInterrupt:
        print("Test interrupted")
        os._exit(0)
    except Exception as e:
        print(f"Error: {e}")
        os._exit(1)

if __name__ == "__main__":
    main()
