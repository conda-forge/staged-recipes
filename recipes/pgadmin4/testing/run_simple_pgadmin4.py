import os
import signal
import sys
import threading
import time


def signal_handler(sig, frame):
    print("Shutting down pgAdmin4 gracefully...")
    # Give some time for cleanup
    time.sleep(1)
    os._exit(0)

# Register signal handler
signal.signal(signal.SIGINT, signal_handler)

threading.Timer(
    30,
    lambda: os.kill(os.getpid(),signal.SIGINT)
).start()

try:
    from pgadmin4.pgAdmin4 import main
    main()
except KeyboardInterrupt:
    # This handles the SIGINT more elegantly
    pass
except Exception as e:
    print(f"Error running pgAdmin4: {e}")
    sys.exit(1)
