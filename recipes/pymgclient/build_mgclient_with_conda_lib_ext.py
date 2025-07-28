import glob
from pathlib import Path
import os
from setuptools import Extension
from setuptools.command.build_ext import build_ext

class GccBuildExt(build_ext):
    def build_extensions(self):
        if sys.platform == "win32":
            # Try to find gcc in PATH first
            import subprocess
            try:
                result = subprocess.run(['where', 'x86_64-w64-mingw32-gcc.exe'],
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    cc_path = result.stdout.strip().split('\n')[0]  # First match
                    print(f"DEBUG: Found GCC via 'where': {cc_path}")

                    if os.path.exists(cc_path):
                        cxx_path = cc_path.replace('gcc.exe', 'g++.exe')
                        print(f"DEBUG: Using GCC: {cc_path}")

                        from distutils.cygwinccompiler import Mingw32CCompiler
                        self.compiler = Mingw32CCompiler()
                        self.compiler.set_executables(
                            compiler=cc_path,
                            compiler_so=cc_path,
                            compiler_cxx=cxx_path,
                            linker_exe=cc_path,
                            linker_so=cc_path
                        )
                        self.compiler.initialize()
                        super().build_extensions()
                        return
            except Exception as e:
                print(f"DEBUG: 'where' command failed: {e}")

            print("DEBUG: Could not find GCC")

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
  
