import os
import signal
import threading
import time
import requests


def setup_signal_handler():
    """Set up a signal handler for graceful shutdown."""
    def signal_handler(sig, frame):
        print("Shutting down gracefully...")
        time.sleep(1)
        os._exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)


def setup_timeout(seconds=60):
    """Set up a timeout that will terminate the program if exceeded."""
    def timeout_handler():
        print(f"Timeout reached after {seconds} seconds - terminating test")
        # Print thread info to help diagnose where it might be stuck
        print("Active threads at timeout:")
        for thread in threading.enumerate():
            print(f"  - {thread.name}")
        os._exit(2)
    
    timer = threading.Timer(seconds, timeout_handler)
    timer.start()
    return timer


def wait_for_server(url="http://127.0.0.1:5050/login", max_attempts=10, 
                    wait_seconds=2, timeout=5):
    """Wait for server to start by repeatedly checking the URL."""
    print(f"Waiting for server to start at {url}...")
    
    for attempt in range(max_attempts):
        try:
            time.sleep(wait_seconds)
            response = requests.get(url, timeout=timeout)
            # Consider both 200 and 401 as successful responses for the login page
            if response.status_code in [200, 401]:
                print(f"Server is up! Status code: {response.status_code}")
                return True
        except requests.exceptions.RequestException:
            print(f"Attempt {attempt+1}/{max_attempts} - Server not ready yet")
    
    print("Server failed to start properly")
    return False
