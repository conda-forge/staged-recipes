import os
import unittest
from pathlib import Path

# set the required environment variables
os.environ['ISISROOT'] = 'fakeISISROOT'
os.environ['ISIS3DATA'] = 'fakeISISROOT'

# create a fake ISISROOT
bindir = Path(os.environ['ISISROOT']) / 'bin'
xmldir = bindir / 'xml'
xmldir.mkdir(parents=True)

# Don't actually need fake files for kalasiris to load, just the
#       directory structure, and then no functions will be added.
# import stat
# # make some fake files
# stats_program = bindir / 'stats'
# stats_program.touch(mode=stat.S_IXUSR)
#
# stats_xml = xmldir / 'stats.xml'
# stats_xml.touch()

# Import check for kalasiris
import kalasiris

# Tests that don't require ISIS to be installed
import tests.test_kalasiris as tk
suite = unittest.TestLoader().loadTestsFromNames(['TestParams.test_format',
                                                  'TestParams.test_reserved_param'],
                                                 module=tk)
unittest.TextTestRunner().run(suite)
