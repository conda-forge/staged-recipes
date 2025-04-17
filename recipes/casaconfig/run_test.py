# Test automatic population of the CASA data, needed to be able to import
# `casatools`.

# Temporary workaround: staged-recipes builds this recipe on all platforms
# even though it's `noarch: python`; Windows has no build script so the
# package is empty and the import fails. That's not actually a problem but
# to ensure things are tidy:

import sys

if sys.platform == "win32":
    sys.exit(0)

# We can remove this workaround once out of staged-recipes

from casaconfig import do_auto_updates, config

print("success:", config.load_success())
print("failure:", config.load_failure())
print("Will now download ~1 GB of CASA data ...")
do_auto_updates(config, logger=None, verbose=True)
print("Checking steady-state ...")
# This invocation should be a no-op:
do_auto_updates(config, logger=None, verbose=True)
