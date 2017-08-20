#!/usr/bin/env bash

ipcluster start --daemonize=True;

# Give some time for the cluster to start up.
sleep 20;

# Run the test suite
python -c "import pygmo_plugins_nonfree; pygmo_plugins_nonfree.test.run_test_suite()"

# Stop the cluster.
ipcluster stop
