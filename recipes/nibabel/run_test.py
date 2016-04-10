import nose
import sys
import re

splatform = sys.platform
if splatform.startswith('win32'):
    # Installation of data files for script testing a bit rickety on Appveyor:
    config = nose.config.Config(verbosity=2,
                                exclude=[re.compile("test_scripts"),
                                         re.compile("test_dft")])
else:
    config = nose.config.Config(verbosity=2)

nose.runmodule('nibabel', config=config)
