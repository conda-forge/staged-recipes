import os
import sys
import argparse
import glob
import shutil
import site


def copy_so(source_dir, dest_dir):

  suffix = ''
  if sys.platform.startswith('linux'):
    suffix = '*.so*'
  elif sys.platform.startswith('win32'):
    suffix = '*.dll'
  elif sys.platform.startswith('darwin'):
    suffix = '*.dylib*'
  else:
    raise NotImplementedError('Unsupported platform')

  source_path = os.path.join(source_dir, 'lib', suffix)

  files = glob.glob(source_path)

  if sys.platform.startswith('win32'):
    dest_dir = os.path.join(dest_dir, 'bin')
  else:
    dest_dir = os.path.join(dest_dir, 'lib')


  for f in files:
    shutil.copy(f, dest_dir, follow_symlinks=False)



def copy_python(source_dir):

  source_path = os.path.join(source_dir, 'python', 'pcraster')

  dest_dir = site.getsitepackages()

  site_packages = [path for path in dest_dir if "site-packages" in path][0]

  dest_dir = os.path.join(site_packages, 'pcraster')

  shutil.copytree(source_path, dest_dir)







if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("source", type=str, help="Temporary installation directory")
  parser.add_argument("dest", type=str, help="Target directory")
  args = parser.parse_args()


  copy_so(args.source, args.dest)

  copy_python(args.source)

  sys.exit(0)
