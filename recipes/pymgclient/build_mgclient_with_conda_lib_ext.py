"""
This code is the result of fastidious trial/error in order to correctly find/use/compile
pymgclient with the conda mgclient library
"""

import glob
from pathlib import Path
import os
import sys
from setuptools import Extension
from setuptools.command.build_ext import build_ext

class GccBuildExt(build_ext):
  """Redefine the method to find conda toolchain gcc on Windows"""
  def build_extensions(self):
    if sys.platform == "win32":
      import subprocess
      try:
        import shutil
        cc_path = shutil.which('x86_64-w64-mingw32-gcc.exe')

        if cc_path and os.path.exists(cc_path):
          # Use forward slashes to avoid backslash issues
          cc_path = cc_path.replace('\\', '/')

          from distutils.unixccompiler import UnixCCompiler

          self.compiler = UnixCCompiler()

          # Set proper MinGW flags (not Cygwin flags)
          self.compiler.set_executables(
            compiler=cc_path,
            compiler_so=cc_path,
            linker_exe=cc_path,
            linker_so=cc_path
          )

          # Override the problematic flags
          self.compiler.compile_options = ['-O2']  # Remove -mcygwin
          self.compiler.compile_options_debug = ['-g', '-O0']

          # Set proper shared library settings for Windows
          self.compiler.shared_lib_extension = '.dll'
          self.compiler.exe_extension = '.exe'
        else:
          print("DEBUG: GCC not found")

      except Exception as e:
        import traceback
        traceback.print_exc()

    super().build_extensions()



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
    if sys.platform == "win32":
      # Windows-specific paths
      prefix = os.environ.get('PREFIX', '')
      include_dirs = [
        os.path.join(prefix, 'Library', 'include'),
        os.path.join(prefix, 'include')
      ]
      library_dirs = [
        os.path.join(prefix, 'Library', 'lib'),
        os.path.join(prefix, 'lib'),
        os.path.join(prefix, 'libs'),
      ]
      libraries = ['mgclient']
    else:
      # Unix-like systems
      base_path = Path(os.environ.get('PREFIX', ''))
      include_dirs = [str(base_path / 'include')]
      library_dirs = [str(base_path / 'lib')]
      libraries = ['mgclient']

  ext = Extension(
    "mgclient",
    sources=get_source_files(),
    include_dirs=include_dirs,
    library_dirs=library_dirs,
    libraries=libraries,
    language="c"
  )
  
  # On Windows, don't link against python39.lib - extensions don't need it
  if sys.platform == "win32":
    ext.extra_link_args = ['-shared']

  return ext
