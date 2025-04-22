import os
import signal
import sys
import threading
import time


def signal_handler(sig, frame):
    print("Shutting down setup gracefully...")
    # Give some time for cleanup
    time.sleep(1)
    sys.exit(0)

# Register signal handler
signal.signal(signal.SIGINT, signal_handler)

threading.Timer(
    60,
    lambda: os.kill(os.getpid(),signal.SIGINT)
).start()

try:
    # Set up sys.argv to simulate CLI arguments for the cleanup_session_files command
    sys.argv = ['pgadmin4-cli', 'cleanup-session-files']

    # Import and run the CLI app
    from pgadmin4.setup import main

    main()
except KeyboardInterrupt:
    # This handles the SIGINT more elegantly
    pass
except Exception as e:
    if (
        "SQLite database file" not in str(e)
        or "pgadmin4.db" not in str(e)
        or "does not exists." not in str(e)
    ):
        print(f"Error running cleanup_session_files: {e}")
        sys.exit(1)
