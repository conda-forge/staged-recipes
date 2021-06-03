"""Help CMake to find opencv libraries on Windows. It has trouble because
   it can't use pkg-config to get names, and the libraries are installed
   with a version-dependent suffix (e.g. opencv_core451.lib). Work around
   this by making a copy of each .lib without the suffix."""

import sys
import os
import re
import shutil


prefix = sys.argv[1]
wanted_libs = ['opencv_core', 'opencv_imgproc', 'opencv_highgui',
               'opencv_imgcodecs']

libdir = os.path.join(prefix, 'Library', 'lib')
os.chdir(libdir)

matches = [re.match('opencv_core(\d+)\.lib$', x) for x in os.listdir('.')]
opencv, = [m for m in matches if m]
suffix = opencv.group(1)

for lib in wanted_libs:
    print("copy %s%s.lib %s.lib" % (lib, suffix, lib))
    shutil.copy("%s%s.lib" % (lib, suffix), "%s.lib" % lib)
