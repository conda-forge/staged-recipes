import os
import threading
import importlib.util
from pgadmin_test_utils import setup_signal_handler, setup_timeout, wait_for_server

# Register signal handler
setup_signal_handler()

# Set a reasonable timeout
timer = setup_timeout(60)

try:
    # Check if pgadmin4 module is available
    if importlib.util.find_spec("pgadmin4") is None:
        print("Error: pgadmin4 module not found. Make sure it's installed properly.")
        os._exit(1)

    # Start pgAdmin4 in a separate thread
    def run_pgadmin():
        try:
            from pgadmin4.pgAdmin4 import main
            main()
        except Exception as e:
            print(f"Error in pgAdmin thread: {e}")

    pgadmin_thread = threading.Thread(target=run_pgadmin)
    pgadmin_thread.daemon = True
    pgadmin_thread.start()

    # Wait for server to start
    print("Starting pgAdmin 4...")
    if wait_for_server():
        # Cancel the timeout timer
        timer.cancel()
        print("Test completed - pgAdmin4 started successfully")
        os._exit(0)
    else:
        os._exit(1)

except KeyboardInterrupt:
    print("Test interrupted")
    os._exit(0)
except Exception as e:
    print(f"Error: {e}")
    os._exit(1)
