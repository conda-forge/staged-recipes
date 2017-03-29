"""
Test whether spyder_line_profiler is installed

Importing spyder_line_profiler requires a running X server on Linux,
so we wrap the import inside an Xvfb (X virtual framebuffer).
"""

from xvfbwrapper import Xvfb

vdisplay = Xvfb()
vdisplay.start()
import spyder_line_profiler
vdisplay.stop()
