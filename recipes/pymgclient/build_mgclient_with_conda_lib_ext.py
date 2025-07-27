import glob
from pathlib import Path
import os
from setuptools import Extension


def get_source_files():
  """Dynamically find all .c files in src/ directory"""
  src_dir = "src"
  if os.path.exists(src_dir):
      return glob.glob(os.path.join(src_dir, "*.c"))
  return []


def build_mgclient_with_conda_lib_ext():
  """Create extension using system-installed mgclient library."""
  import subprocess

  # Try pkg-config first
  try:
      subprocess.run(['pkg-config', '--exists', 'mgclient'], check=True)
      cflags = subprocess.check_output(['pkg-config', '--cflags', 'mgclient']).decode().strip()
      libs = subprocess.check_output(['pkg-config', '--libs', 'mgclient']).decode().strip()

      include_dirs = [flag[2:] for flag in cflags.split() if flag.startswith('-I')]
      library_dirs = [flag[2:] for flag in libs.split() if flag.startswith('-L')]
      libraries = [flag[2:] for flag in libs.split() if flag.startswith('-l')]
  except:
      # Fallback to environment variables or common paths
      base_path = Path(os.environ.get('PREFIX', ''))
      include_dirs = [str(Path(base_path) / 'include')]
      library_dirs = [str(Path(base_path) / 'lib')]
      libraries = ['mgclient']

  return Extension(
      "mgclient",
      sources=get_source_files(),
      include_dirs=include_dirs,
      library_dirs=library_dirs,
      libraries=libraries,
      language="c"
  )