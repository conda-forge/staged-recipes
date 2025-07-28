import glob
from pathlib import Path
import os
import sys
from setuptools import Extension
from setuptools.command.build_ext import build_ext

class GccBuildExt(build_ext):
  def build_extensions(self):
    if sys.platform == "win32":
      import subprocess
      try:
        # Debug the where command itself
        print(f"DEBUG: Running 'where x86_64-w64-mingw32-gcc.exe'...")
        result = subprocess.run(
          ['where', 'x86_64-w64-mingw32-gcc.exe'],
          capture_output=True, text=True
        )
        print(f"DEBUG: where returncode: {result.returncode}")
        print(f"DEBUG: where stdout: {repr(result.stdout)}")
        print(f"DEBUG: where stderr: {repr(result.stderr)}")

        if result.returncode == 0:
          cc_path = result.stdout.strip().split('\n')[0]
          print(f"DEBUG: Extracted path: {repr(cc_path)}")

          # Let's also try a different approach - check PATH directly
          path_env = os.environ.get('PATH', '')
          print(f"DEBUG: PATH contains gcc location: {'x86_64-w64-mingw32-gcc.exe' in path_env}")

          # Try using shutil.which instead
          import shutil
          which_result = shutil.which('x86_64-w64-mingw32-gcc.exe')
          print(f"DEBUG: shutil.which result: {repr(which_result)}")

          if which_result:
            cc_path = which_result
            print(f"DEBUG: Using shutil.which result: {cc_path}")

          if os.path.exists(cc_path):
            print(f"DEBUG: GCC exists at: {cc_path}")
            from distutils.cygwinccompiler import Mingw32CCompiler
            self.compiler = Mingw32CCompiler()
            self.compiler.set_executables(
              compiler=cc_path,
              compiler_so=cc_path,
              linker_exe=cc_path,
              linker_so=cc_path
            )
            self.compiler.initialize()
            super().build_extensions()
            print(f"DEBUG: Done")
            return
          else:
              print(f"DEBUG: GCC not found at: {repr(cc_path)}")
      except Exception as e:
        print(f"DEBUG: Exception: {e}")
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
          prefix = os.environ.get('LIBRARY_PREFIX') or os.environ.get('PREFIX', '')
          print(f"DEBUG: Windows PREFIX={prefix}")

          include_dirs = [
              os.path.join(prefix, 'Library', 'include'),
              os.path.join(prefix, 'include')
          ]
          library_dirs = [
              os.path.join(prefix, 'Library', 'lib'),
              os.path.join(prefix, 'lib')
          ]
          libraries = ['mgclient']

          # Debug: check if library exists
          for lib_dir in library_dirs:
              lib_file = os.path.join(lib_dir, 'libmgclient.a')
              dll_file = os.path.join(lib_dir, 'mgclient.lib')
              print(f"DEBUG: Checking for library at {lib_file}: {os.path.exists(lib_file)}")
              print(f"DEBUG: Checking for library at {dll_file}: {os.path.exists(dll_file)}")
      else:
          # Unix-like systems
          base_path = Path(os.environ.get('PREFIX', ''))
          include_dirs = [str(base_path / 'include')]
          library_dirs = [str(base_path / 'lib')]
          libraries = ['mgclient']

  return Extension(
      "mgclient",
      sources=get_source_files(),
      include_dirs=include_dirs,
      library_dirs=library_dirs,
      libraries=libraries,
      language="c"
  )
  
