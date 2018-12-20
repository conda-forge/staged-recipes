from xvfbwrapper import Xvfb
import subprocess
import sys
vdisplay = Xvfb()
vdisplay.start()
rc = subprocess.check_call(["ggobi", "--version"])
vdisplay.stop()
sys.exit(rc)
