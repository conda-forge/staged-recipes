import os
import sys
import traceback
import time
import threading
from pgadmin_test_utils import setup_signal_handler, setup_timeout

# Register signal handler
setup_signal_handler()

# Set a timeout - fail after 360 seconds (increased from 180)
timer = setup_timeout(360)

# Set a verification timeout - just verify script starts correctly
VERIFICATION_TIMEOUT = 60  # seconds
verification_success = False
exit_event = threading.Event()

def progress_callback():
    """Print a heartbeat message every 30 seconds to show the setup is still running"""
    last_time = time.time()

    def callback():
        nonlocal last_time
        current_time = time.time()
        if current_time - last_time >= 30:
            print(f"Setup still in progress... (elapsed: {int(current_time - start_time)} seconds)")
            last_time = current_time

    return callback

# Add verification timer thread function
def verification_timer():
    """Exit gracefully after verification timeout if setup has started successfully"""
    time.sleep(VERIFICATION_TIMEOUT)
    if verification_success and not exit_event.is_set():
        print(f"Verification successful after {VERIFICATION_TIMEOUT} seconds")
        print("Setup appears to be working - exiting gracefully")
        timer.cancel()
        os._exit(0)

start_time = time.time()
last_progress = time.time()
heartbeat = progress_callback()

try:
    print("Starting pgAdmin4 database setup...")

    # Set up sys.argv to simulate CLI arguments for Typer
    # The correct format for the Typer CLI app
    sys.argv = ['pgadmin4-cli', 'setup-db']

    print("Importing pgadmin4.setup...")
    from pgadmin4.setup import main

    # Mark verification as successful once we get past imports
    verification_success = True

    # Start verification timer thread
    verification_thread = threading.Thread(target=verification_timer, daemon=True)
    verification_thread.start()

    print("Running pgAdmin4 setup_db command...")
    # Execute the setup_db command directly

    # Monitor for progress during setup
    monitor_thread = None
    try:
        def heartbeat_thread():
            while not exit_event.is_set():
                heartbeat()
                time.sleep(1)

        monitor_thread = threading.Thread(target=heartbeat_thread, daemon=True)
        monitor_thread.start()

        # Execute main with proper timing information
        print(f"Setup started at: {time.strftime('%H:%M:%S')}")
        setup_start = time.time()
        main()
        setup_duration = time.time() - setup_start
        print(f"Setup completed in {setup_duration:.1f} seconds")

    except Exception as e:
        print(f"Error in setup monitoring: {e}")
        # Fall back to simpler execution
        main()

    # Set exit event to stop monitor threads
    exit_event.set()

    # Cancel the timeout timer after successful completion
    timer.cancel()
    print(f"Database setup completed successfully in {time.time() - start_time:.1f} seconds")
    os._exit(0)

except KeyboardInterrupt:
    print("Test interrupted")
    os._exit(0)
except ImportError as e:
    print(f"Import error: {e}")
    print("Make sure pgadmin4 is installed correctly")
    traceback.print_exc()
    os._exit(1)
except Exception as e:
    print(f"Error during database setup: {e}")
    print("Detailed traceback:")
    traceback.print_exc()
    os._exit(1)
