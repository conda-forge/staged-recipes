#!/usr/bin/env python3
import os
import pathlib
import shlex
import shutil
import subprocess
import platform

is_windows = platform.system().lower()=='windows'

prefix = pathlib.Path(os.environ['PREFIX']).absolute().resolve()
assert prefix.is_dir()
src = ( pathlib.Path('.') / 'src' ).absolute().resolve()
assert src.is_dir()

_print=print
def print(*args,**kwargs):
    _print('install-files-core.py::',*args,**kwargs)
def fatal_error(*args,**kwargs):
    _print('ERROR install-files-core.py::',*args,**kwargs)
    raise SystemExit(1)

def launch( cmd ):
    cmd_str = ' '.join(shlex.quote(str(e)) for e in cmd)
    print(f'Launching command: {cmd_str}')
    res = subprocess.run( cmd )
    if res.returncode != 0:
        fatal_error('Command failed!')

cmake_cmd = shutil.which('cmake')
if not cmake_cmd:
    fatal_error('could not find cmake command')

cmake_flags = [ f'-DCMAKE_INSTALL_PREFIX={prefix}',
                '-S',src,
                '-DBUILD_SHARED_LIBS=ON',
                '-DCMAKE_INSTALL_LIBDIR=lib',
                '-DCMAKE_BUILD_TYPE=Release',
                '-DBUILD_MCSTAS=ON',
                '-DMCCODE_USE_LEGACY_DESTINATIONS=OFF',
                '-DBUILD_TOOLS=ON',
                '-DENABLE_COMPONENTS=ON',
                '-DENSURE_MCPL=OFF',
                '-DENSURE_NCRYSTAL=OFF',
                '-DENABLE_CIF2HKL=OFF',
                '-DENABLE_NEUTRONICS=OFF'
               ]

cmake_flags += shlex.split( os.environ.get('CMAKE_ARGS','') )

if is_windows:
    cmake_flags += ['-G','NMake Makefiles']
else:
    cmake_flags += ['-G','Unix Makefiles']

env_python = os.environ.get('PYTHON')
if env_python:
    cmake_flags += [ f'-DPython3_EXECUTABLE={env_python}' ]

build = ( pathlib.Path('.') / 'build' ).absolute().resolve()
build.mkdir()
os.chdir(build)

launch( [ cmake_cmd ] + cmake_flags )
launch( [ cmake_cmd, '--build', '.','--config','Release'] )
launch( [ cmake_cmd, '--build', '.','--target','install','--config','Release'] )

for f in ['bin/mcstas',
          'bin/mcrun',
          'share/mcstas/tools/Python/mccodelib/__init__.py',
          'share/mcstas/resources/data']:
    if not prefix.joinpath(*(f.split('/'))).exists():
        fatal_error('Installation did not provide expected: <prefix>/%s'%f)

#Data files will be provided in mcstas-data package instead:
datadir = prefix / 'share' / 'mcstas' / 'resources' / 'data'
assert datadir.is_dir()
shutil.rmtree(datadir)

#Temporary workarounds:
for f in [ ( prefix / 'bin' / 'postinst' ) ]:
    if f.exists():
        f.unlink()
f = prefix / 'bin' / 'acc_gpu_bind'
if f.exists():
    f.rename( prefix / 'bin' / 'mcstas-acc_gpu_bind')
