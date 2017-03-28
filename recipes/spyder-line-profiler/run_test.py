"""
Test whether spyder_line_profiler is installed

The test is only whether the module can be found. It does not attempt
to import the module because this needs an X server.
"""

import imp
imp.find_module('spyder_line_profiler')
