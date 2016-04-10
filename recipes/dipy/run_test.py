import nose
config = nose.config.Config(verbosity=2)
nose.runmodule('dipy', config=config)
