# The import tests in here should be only those that
# 1. Require an X11 display on linux

import pyglet.font
import pyglet.gl
import pyglet.graphics
import pyglet.image
import pyglet.image.codecs
import pyglet.input
import pyglet.media
import pyglet.media.drivers
import pyglet.media.drivers.directsound
import pyglet.window
import pyglet.text
import pyglet.text.formats

# Handle an import that should only happen on linux and requires
# a display.
import sys

if sys.platform.startswith('linux'):
    import pyglet.window.xlib
