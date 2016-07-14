# The import tests in here should be only those that
# 1. Require an X11 display on linux

test_imports = [
    'pyglet.font',
    'pyglet.gl',
    'pyglet.graphics',
    'pyglet.image',
    'pyglet.image.codecs',
    'pyglet.input',
    'pyglet.media',
    'pyglet.media.drivers',
    'pyglet.media.drivers.directsound',
    'pyglet.window',
    'pyglet.text',
    'pyglet.text.formats',
]

def expected_fail(module):
    try:
        print('Importing {}'.format(module))
        __import__(module)
    except Exception as e:
        # Yes, make the exception general, because we can't import the specific
        # exception on linux without an actual display. Look at the source
        # code if you want to see why.
        assert 'No standard config is available.' in str(e)

# Handle an import that should only happen on linux and requires
# a display.

for module in test_imports:
    expected_fail(module)

import sys

if sys.platform.startswith('linux'):
    expected_fail('pyglet.window.xlib')

# And another import that is expected to fail in...

if sys.platform == 'darwin':
    expected_fail('pyglet.window.cocoa')
