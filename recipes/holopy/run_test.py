import nose
config = nose.config.Config(verbosity=1)
nose.runmodule('holopy', config=config)
