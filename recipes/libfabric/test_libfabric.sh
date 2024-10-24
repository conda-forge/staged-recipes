#!/bin/bash
set -ex

# Start the server in the background
fi_pingpong -v &
SERVER_PID=$!

# Give the server a moment to initiate
sleep 2

# Start the client pointing to the localhost
fi_pingpong -v 127.0.0.1
