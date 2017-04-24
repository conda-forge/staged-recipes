# this test is intended to verify that the plugin has been
#    registered correctly with pytest.
import os
import subprocess
import sys

on_win = sys.platform=="win32"

prefix = os.environ['PREFIX'].replace("\\", '/')
subdir = "Scripts" if on_win else "bin"
prefix = os.path.join(prefix, subdir)

cmd = '{prefix}/py.test{ext} -h'.format(prefix=prefix,
                                sep=os.path.sep,
                                ext=".exe" if on_win else "")
cmd = 'py.test -h'
output = subprocess.check_output(cmd.split(), env=os.environ)
if hasattr(output, 'decode'):
    output = output.decode('utf-8')
assert '--no-print-logs' in output
