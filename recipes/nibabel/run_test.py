import nose
import sys
splatform = sys.platform
if splatform.startswith('win32'):
    # Installation of data files for script testing a bit rickety on Appveyor:
    config = nose.config.Config(verbosity=2, exclude="test_scripts")
else:
    config = nose.config.Config(verbosity=2)

nose.runmodule('nibabel', config=config)
