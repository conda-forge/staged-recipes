"""
Tool for initial rpath fix for extensions
"""
from __future__ import absolute_import, division, print_function

import os
import glob

from subprocess import check_output

# =============================================================================
if __name__ == '__main__':
  exe_dev_files = glob.glob('build/exe_dev/*')
  ext_files = glob.glob('build/lib/*_ext.so')
  lib_files = glob.glob('build/lib/*.dylib')
  test_files = glob.glob('build/**/tst_*', recursive=True) \
               + glob.glob('build/**/timing/*', recursive=True) \
               + glob.glob('build/**/boost_python/*.so', recursive=True)
  for ext_file in exe_dev_files + ext_files + lib_files + test_files:
    libraries = check_output([os.environ['OTOOL'], '-L', ext_file]).decode('utf8').split('\n')
    for line in libraries[1:]:
      lib = line.replace('\t', '').split()
      if len(lib) > 0:
        lib = lib[0]
        new_lib = None
        if lib.startswith('lib/'):
          new_lib = os.path.join('@rpath', lib.split('/')[1])
        elif lib.startswith('@rpath/lib/'):
          new_lib = os.path.join('@rpath', lib.split('/')[2])
        if new_lib is not None:
          cmd = ['install_name_tool', '-change', lib, new_lib, ext_file]
          print(' '.join(cmd))
          output = check_output(cmd)
