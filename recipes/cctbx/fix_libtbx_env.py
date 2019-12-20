"""
Script to update libtbx_env contents
"""
from __future__ import absolute_import, division, print_function

import os
import sys

if os.getenv('LIBTBX_BUILD') is None:
  os.environ['LIBTBX_BUILD'] = sys.prefix

import libtbx.load_env

from libtbx.path import relocatable_path, absolute_path

if __name__ == '__main__':

  # basic path changes
  env = libtbx.env
  env.build_path = absolute_path(sys.prefix)
  env.set_derived_paths()
  env.pythonpath = list()
  env.python_exe = env.as_relocatable_path(sys.executable)
  env.no_bin_python = True

  # libtbx.python dispatcher
  env._write_dispatcher_in_bin(
    source_file=env.python_exe,
    target_file='libtbx.python',
    source_is_python_exe=True)

  # update module locations
  for name in env.module_dict:
    module = env.module_dict[name]
    new_anchor = None
    new_path = None
    for path in sys.path:
      new_path = os.path.join(path, name)
      if os.path.isdir(new_path):
        new_anchor = env.build_path
        new_path = relocatable_path(new_anchor, new_path)
        break

    if new_anchor is not None and new_path is not None:
      dist_paths = module.dist_paths
      for i, path in enumerate(dist_paths):
        if path is not None:
          module.dist_paths[i] = new_path
      env.module_dist_paths[name] = new_path

  # update dispatchers
  for module in env.module_list:
    module.process_command_line_directories()

  # repickle
  env.pickle()
