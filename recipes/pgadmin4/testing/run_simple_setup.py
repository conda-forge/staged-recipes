import os
import sys
import threading
import requests
from pgadmin_test_utils import setup_signal_handler, setup_timeout, wait_for_server

# Register signal handler
setup_signal_handler()

# Set a reasonable timeout - fail after 60 seconds
timer = setup_timeout(120)

try:
    # Set up sys.argv to simulate CLI arguments
    sys.argv = ['pgadmin4-cli', 'setup-db']

    # Import and run the CLI app to set up the DB
    from pgadmin4.setup import main
    main()

    print("Database setup completed successfully")

    # Try a simple health check by requesting the login page
    try:
        # Start the server in a separate thread
        from pgadmin4 import create_app

        def run_server():
            app = create_app()
            app.run(host='127.0.0.1', port=5050, use_reloader=False)

        server_thread = threading.Thread(target=run_server)
        server_thread.daemon = True
        server_thread.start()

        # Wait for server to start
        if wait_for_server():
            # Cancel the timeout timer
            timer.cancel()
            print("Test completed successfully")
            os._exit(0)
        else:
            os._exit(1)

    except Exception as e:
        print(f"Health check failed: {e}")
        os._exit(1)

except KeyboardInterrupt:
    print("Test interrupted")
    os._exit(0)
except Exception as e:
    print(f"Error during test: {e}")
    os._exit(1)
