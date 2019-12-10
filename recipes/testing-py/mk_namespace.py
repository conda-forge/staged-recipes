import os
common = os.path.join(os.getenv('SP_DIR'), 'testing', 'common')

os.makedirs(common)
with open(os.path.join(common, '__init__.py'), 'w'):
    pass
with open(os.path.join(os.path.dirname(common), '__init__.py'), 'w'):
    pass
