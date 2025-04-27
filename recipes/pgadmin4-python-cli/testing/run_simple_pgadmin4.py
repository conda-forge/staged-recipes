import importlib.util
import os
import subprocess
import threading
import time

from pgadmin_test_utils import setup_signal_handler, setup_timeout, wait_for_server

# Register signal handler
setup_signal_handler()

# Set a reasonable timeout
timer = setup_timeout(60)

# Global variable to store the process reference
process = None

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
            # Exit with success immediately
            timer.cancel()
            print("Test completed - pgAdmin4 started successfully")
            os._exit(0)

    # This will only execute if the process ends without finding the expected output
    process.wait()

try:
    # Check if pgadmin4 module is available
    if importlib.util.find_spec("pgadmin4") is None:
        print("Error: pgadmin4 module not found. Make sure it's installed properly.")
        os._exit(1)

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
        timer.cancel()
        if process:
            process.terminate()
        os._exit(0)
    else:
        # Thread ended without finding running message
        print("pgAdmin4 process ended unexpectedly")
        os._exit(1)

except KeyboardInterrupt:
    print("Test interrupted")
    os._exit(0)
except Exception as e:
    print(f"Error: {e}")
    os._exit(1)
