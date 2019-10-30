"""
Installation script for Python components
The python used to call this script is the default location of the installation.
"""
from __future__ import absolute_import, division, print_function

import argparse
import glob
import os
import sys

import libtbx.load_env

# =============================================================================
def find_python_files(directory):
  """
  Function to find the Python files in a directory

  Parameters
  ----------
    directory: str
      The directory to search

  Returns
  -------
    file_list: list
      List of filenames
  """
  cwd = os.getcwd()
  file_list = list()
  for dirpath, dirnames, filenames in os.walk(directory):
    os.chdir(directory)
    filenames = glob.glob('*.py')
    file_list += [filename if dirpath == '.'
                  else os.path.join(dirpath, filename)
                  for filename in filenames]
    for dirname in dirnames:
      if not dirname.startswith('.'):
        file_list += find_python_files(dirname)
  os.chdir(cwd)

  return file_list

# =============================================================================
def create_setup_files(module_list, filename=None, file_template=None):
  """
  Function for creating the setup.py file

  If a filename is provided, all the modules are added to the same file.
  Otherwise, each module has a separate file. A file template for the setup.py
  file can also be provided. There should be fields for {module} and {version}

  Parameters
  ----------
    module_list: list
      List of modules for creating the setup.py file
    filename: str
      The common filename for all the modules
    file_template: str
      The setup.py template

  Returns
  -------
    Nothing
  """

  if file_template is None:
    file_template = """
from setuptools import setup, find_packages
setup(
    name='{module}',
    version='{version}',
    description='{module} module from CCTBX',
    url='https://github.com/cctbx/cctbx_project',
    packages=find_packages(include=['{module}', '{module}.*']),
)
"""


# =============================================================================
def run_setup(version='0.0', create_files=True, run_files=True, log=sys.stdout):
  """
  Function to iterate over each configured module and create a setup.py file to
  install the Python components.

  Parameters
  ----------
  create_files: bool
    If set, the setup.py files are created per module
  run_files: bool
    If set, the setup.py files are run to install the Python files
  log: file
    For storing the log output

  Returns
  -------
    0 for sucess, 1 for failure
  """

  cwd = os.getcwd()
  env = libtbx.env
  modules = env.module_list
  modules_path = abs(env.repository_paths[0])

  ignored_modules = [
    'chem_data',
    'phenix_examples',
    'phenix_regression',
  ]

  cctbx_file_template = """
from setuptools import setup, find_packages
setup(
    name='{module}',
    version='{version}',
    description='{module} module from CCTBX',
    url='https://github.com/cctbx/cctbx_project',
    packages=find_packages(include=[{packages}]),
)
"""

  file_template = """
from setuptools import setup, find_packages
setup(
    name='{module}',
    version='{version}',
    description='{module} module from CCTBX',
    url='https://github.com/cctbx/cctbx_project',
    packages=find_packages(include=['{module}', '{module}.*']),
)
"""

  # ---------------------------------------------------------------------------
  # create setup.py files
  if create_files:
    print('Creating setup.py files', file=log)
    print('=======================', file=log)

    os.chdir(modules_path)
    directory = None

    # separate cctbx_project modules
    cctbx_modules = list()
    other_modules = list()
    for module in modules:
      for name, directory in module.name_and_dist_path_pairs():
        if directory is not None:
          if 'cctbx_project' in abs(directory):
            cctbx_modules.append(module)
          else:
            other_modules.append(module)

    # cctbx_project first (main cctbx package)
    filename = os.path.join(env.under_dist('cctbx', '..'), 'cctbx_setup.py')
    packages = list()
    for module in cctbx_modules:
      for name, directory in module.name_and_dist_path_pairs():
        if directory is not None:
          module_has_python_files = len(find_python_files(abs(directory)))
          if module_has_python_files:
            packages.append("'{module}'".format(module=name))
            packages.append("'{module}.*'".format(module=name))

            # with open(filename.format(module=name), 'w') as f:
            #   f.write(file_template.format(module=name, version=version))
            # if os.path.isfile(filename.format(module=name)):
            #   print('Wrote {filename}'.format(
            #     filename=filename.format(module=name)), file=log)
            # else:
            #   raise RuntimeError("""{filename} failed to write.""".format(
            #     filename=filename))
          else:
            print('{module} does not have Python files'.format(module=name),
                  file=log)
    packages = ', '.join(packages)
    print(file=log)
    print('cctbx_setup.py will contain:', file=log)
    print(packages, file=log)
    with open(filename, 'w') as f:
      f.write(cctbx_file_template.format(module='cctbx', version=version,
                                         packages=packages))
    print('Wrote {filename}'.format(filename=filename), file=log)

    # other modules
    filename = '{module}_setup.py'

    print(file=log)

  # ---------------------------------------------------------------------------
  # install
  if run_files:
    print(namespace.prefix)

  print()
  os.chdir(cwd)

# =============================================================================
if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument(
    '--prefix', default=sys.prefix, type=str, nargs='?',
    help="""The installation directory. By default, the location is where
      Python is located (e.g. sys.prefix)""")
  parser.add_argument(
    '--version', default='0.0', type=str, nargs='?',
    help="""The version number of the package""")
  parser.add_argument(
    '--only-create-files', action='store_true',
    help="""When set, the setup.py files are only created (not run) for each
      configured module.""")
  parser.add_argument(
    '--only-run-files', action='store_true',
    help="""When set, the setup.py files are run for each configured
      module. The command will fail if the setup.py does not exist. Default
      is True.""")

  namespace = parser.parse_args()

  if namespace.only_create_files and namespace.only_run_files:
    raise RuntimeError("""
Only one of the --only-create-files or --only-run-files flags can be used.
""")

  create_files = True
  run_files = True
  if namespace.only_create_files:
    run_files = False
  elif namespace.only_run_files:
    create_files = False

  sys.exit(run_setup(version=namespace.version, create_files=create_files, run_files=run_files))
