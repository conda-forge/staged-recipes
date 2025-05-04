import importlib.util
import os
import subprocess
import threading
import time
import signal
import sys
import socket
import psutil

# Global variables
process = None
startup_detected = threading.Event()

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
        for proc in psutil.process_iter(['pid', 'name']):
            try:
                for conn in proc.connections():
                    if conn.laddr.port == port:
                        print(f"Found process {proc.pid} ({proc.name()}) using port {port}")
                        proc.terminate()
                        try:
                            proc.wait(timeout=3)
                        except psutil.TimeoutExpired:
                            print(f"Process {proc.pid} didn't terminate, killing forcefully")
                            proc.kill()
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
            print("Test completed - pgAdmin4 started successfully")
            # Set the event to signal success instead of exiting directly
            startup_detected.set()
            return

    # This will only execute if the process ends without finding the expected output
    process.wait()

# Handle signals
def signal_handler(sig, frame):
    print(f"Received signal {sig}")
    cleanup_and_exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

try:
    # Check if pgadmin4 module is available
    if importlib.util.find_spec("pgadmin4") is None:
        print("Error: pgadmin4 module not found. Make sure it's installed properly.")
        cleanup_and_exit(1)

    # Start pgAdmin4 in a separate thread
    pgadmin_thread = threading.Thread(target=run_pgadmin4)
    pgadmin_thread.daemon = True  # Thread will exit when main thread exits
    pgadmin_thread.start()

    # Add a maximum wait time in the main thread
    start_time = time.time()
    max_wait = 30  # seconds

    # Wait for either success detection or timeout
    while time.time() - start_time < max_wait:
        if startup_detected.is_set():
            # Success detected
            cleanup_and_exit(0)

        if not pgadmin_thread.is_alive():
            # Thread ended without detecting startup
            print("pgAdmin4 process ended unexpectedly")
            cleanup_and_exit(1)

        time.sleep(0.5)

    # If we reach here, timeout occurred
    print("Maximum wait time reached without detecting successful startup")
    cleanup_and_exit(1)

except Exception as e:
    print(f"Error: {e}")
    cleanup_and_exit(1)
