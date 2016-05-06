from cis.test.runner import run
import os

# Disable multi proccesing on windows as it doesn't appear to work
np = 0 if os.name == 'nt' else 1
# Run the tests
run('cis.test.unit', n_processors=np)

# If the test data directory is specified, run the integration tests as well. We disable parallel processing
# of these though as some have side affects, you also have to specify a time-out which would have to be very large
if os.environ.get("CIS_DATA_HOME", None):
    run('cis.test.integration', n_processors=0)
