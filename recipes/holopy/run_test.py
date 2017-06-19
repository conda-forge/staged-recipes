import holopy
from holopy.scattering.theory.mie_f import mieangfuncs, scsmfo_min

import nose
config = nose.config.Config(verbosity=1)
nose.runmodule('holopy.scattering',config=config)
