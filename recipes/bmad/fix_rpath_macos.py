"""
Tool for initial rpath fix for extensions
"""
from __future__ import absolute_import, division, print_function

import os
import glob

from subprocess import check_output

# =============================================================================
if __name__ == '__main__':
  lib_files = glob.glob('production/lib/*.dylib')
  for ext_file in lib_files:
    libraries = check_output([os.environ['OTOOL'], '-L', ext_file]).decode('utf8').split('\n')
    for idx, line in enumerate(libraries[1:]):
      lib = line.replace('\t', '').split()
      if not lib:
        continue
      if len(lib) > 0:
        lib = lib[0]
      if idx == 0:
            new_lib = os.path.join('@rpath', lib.split('/')[-1])
            cmd = [os.environ["INSTALL_NAME_TOOL"], '-id', new_lib, ext_file]
            print('\t\t', ' '.join(cmd))
            output = check_output(cmd)
      else:
          new_lib = None
          if 'production/lib' in lib:
            new_lib = os.path.join('@rpath', lib.split('/')[-1])
          if new_lib is not None:
            cmd = [os.environ["INSTALL_NAME_TOOL"], '-change', lib, new_lib, ext_file]
            print('\t\t', ' '.join(cmd))
            output = check_output(cmd)
