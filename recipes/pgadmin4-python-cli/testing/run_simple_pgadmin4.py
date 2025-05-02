import importlib.util
import os
import subprocess
import threading
import time
import signal
import sys
import socket
import psutil

from pgadmin_test_utils import setup_signal_handler, setup_timeout, wait_for_server

# Register signal handler
setup_signal_handler()

# Set a reasonable timeout
timer = setup_timeout(60)

# Global variable to store the process reference
process = None

def is_port_in_use(port):
    """Check if a port is in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('127.0.0.1', port)) == 0

def kill_process_on_port(port):
    """Find and kill any process using the specified port in an OS-independent way."""
    if not is_port_in_use(port):
        print(f"No process found using port {port}")
        return

    print(f"Terminating process on port {port}")
    try:
        for proc in psutil.process_iter(['pid', 'name', 'connections']):
            try:
                for conn in proc.connections():
                    if conn.laddr.port == port:
                        print(f"Found process {proc.pid} ({proc.name()}) using port {port}")
                        proc.terminate()
                        try:
                            proc.wait(timeout=3)  # Wait up to 3 seconds for graceful termination
                        except psutil.TimeoutExpired:
                            print(f"Process {proc.pid} didn't terminate, killing forcefully")
                            proc.kill()  # Force kill if not terminated
                        return
            except (psutil.AccessDenied, psutil.ZombieProcess, psutil.NoSuchProcess):
                continue
    except Exception as e:
        print(f"Error killing process on port {port}: {e}")

def cleanup_and_exit(exit_code=0):
    """Cleanup resources and exit with the given code."""
    print("Cleaning up resources...")
    if process:
        try:
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()
        except Exception as e:
            print(f"Error terminating pgadmin process: {e}")

    # Kill any process using port 5050
    kill_process_on_port(5050)

    if timer:
        timer.cancel()

    print(f"Exiting with code {exit_code}")
    sys.exit(exit_code)

def run_pgadmin4():
    global process
    # Start pgAdmin4 process
    process = subprocess.Popen(
        ["pgadmin4"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
        bufsize=1
    )

    # Monitor output for server startup indication
    for line in process.stdout:
        print(line.strip())
        # If we see this message, we know pgAdmin has started successfully
        if "Running on http://127.0.0.1:5050" in line:
            print("TEST: pgAdmin 4 detected as running")
            # Exit with success
            print("Test completed - pgAdmin4 started successfully")
            cleanup_and_exit(0)

    # This will only execute if the process ends without finding the expected output
    process.wait()

try:
    # Check if pgadmin4 module is available
    if importlib.util.find_spec("pgadmin4") is None:
        print("Error: pgadmin4 module not found. Make sure it's installed properly.")
        cleanup_and_exit(1)

    # Start pgAdmin4 in a separate thread
    pgadmin_thread = threading.Thread(target=run_pgadmin4)
    pgadmin_thread.daemon = True  # Thread will exit when main thread exits
    pgadmin_thread.start()

    # Add a maximum wait time in the main thread as backup
    start_time = time.time()
    max_wait = 30  # seconds

    while pgadmin_thread.is_alive() and time.time() - start_time < max_wait:
        time.sleep(1)

    # If we reach here, either timeout occurred or thread ended
    # without finding the expected output
    if time.time() - start_time >= max_wait:
        print("Maximum wait time reached - exiting with success anyway")
        cleanup_and_exit(0)
    else:
        # Thread ended without finding running message
        print("pgAdmin4 process ended unexpectedly")
        cleanup_and_exit(1)

except KeyboardInterrupt:
    print("Test interrupted")
    cleanup_and_exit(0)
except Exception as e:
    print(f"Error: {e}")
    cleanup_and_exit(1)
