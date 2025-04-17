# Test automatic population of the CASA data, needed to be able to import
# `casatools`.

from casaconfig import do_auto_updates, config

print("success:", config.load_success())
print("failure:", config.load_failure())
print("Will now download ~1 GB of CASA data ...")
do_auto_updates(config, logger=None, verbose=True)
print("Checking steady-state ...")
# This invocation should be a no-op:
do_auto_updates(config, logger=None, verbose=True)
