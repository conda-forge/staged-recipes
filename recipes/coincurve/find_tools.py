"""Help to find the executables needed to build the library."""

import sys
import os
import re
import shutil

prefix = sys.argv[1]
wanted_bins = ['bash', 'autoreconf']

bindir = os.path.join(prefix, 'Library', 'usr', 'bin')
os.chdir(bindir)

matches = [re.match('opencv_core(\d+)\.lib$', x) for x in os.listdir('.')]
opencv, = [m for m in matches if m]
suffix = opencv.group(1)

for lib in wanted_libs:
    print("copy %s%s.lib %s.lib" % (lib, suffix, lib))
    shutil.copy("%s%s.lib" % (lib, suffix), "%s.lib" % lib)