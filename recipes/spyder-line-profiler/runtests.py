from xvfbwrapper import Xvfb

vdisplay = Xvfb()
vdisplay.start()
import spyder_line_profiler
vdisplay.stop()
