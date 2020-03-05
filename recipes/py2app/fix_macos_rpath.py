"""
Tool for initial rpath fix for prebuilt binaries
"""
from __future__ import absolute_import, division, print_function

import os
import glob

from subprocess import CalledProcessError, check_output

# =============================================================================
if __name__ == '__main__':
  main_files = glob.glob('py2app/apptemplate/prebuilt/main*')
  secondary_files = glob.glob('py2app/apptemplate/prebuilt/secondary*')
  bundle_files = glob.glob('py2app/bundletemplate/prebuilt/main*')
  for bin_file in main_files + secondary_files + bundle_files:
    if os.path.isfile(bin_file):
      print(bin_file)
      libraries = list()
      try:
        libraries = check_output(['otool', '-L', bin_file]).decode('utf8').split('\n')
      except CalledProcessError:
        pass
      for line in libraries[1:]:
        lib = line.strip().split()
        if len(lib) > 0:
          lib = lib[0]
          new_lib = None
          if 'libgcc_s' in lib:
            new_lib = os.path.join('@rpath', lib.split('/')[-1])
          if new_lib is not None:
            print('Changing {lib} to {new_lib}'.format(lib=lib, new_lib=new_lib))
            cmd = ['install_name_tool', '-change', lib, new_lib, bin_file]
            print(' '.join(cmd))
            try:
              output = check_output(cmd)
            except CalledProcessError:
              pass
            cmd = ['install_name_tool', '-add_rpath',
                   os.path.join('@loader_path', '..', 'lib'),
                   bin_file]
            print(' '.join(cmd))
            try:
              output = check_output(cmd)
            except CalledProcessError:
              pass
