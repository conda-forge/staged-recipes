import nose
import sys
import re

verbosity = 1
splatform = sys.platform
if splatform.startswith('win32'):
    # Installation of data files for script testing a bit rickety on Appveyor:
    config = nose.config.Config(verbosity=verbosity,
                                exclude=[re.compile("test_scripts"),
                                         re.compile("test_dft")])
else:
    config = nose.config.Config(verbosity=verbosity)

nose.runmodule('nibabel', config=config)
