import os
from pathlib import Path
import shlex
import subprocess
import sys

source = Path(__file__).with_name('test-lib.c')
windows = sys.platform == 'win32'
prefix = Path(os.environ['CONDA_PREFIX']) / ('Library' if windows else '')
os.environ['PKG_CONFIG_PATH'] = str(prefix / 'lib/pkgconfig')
for name in ['libghostty-vt', 'libghostty-vt-static']:
    # Conda treats its include/lib directories as system paths. Keep them
    # because this direct compiler invocation doesn't consume CFLAGS/LDFLAGS.
    flags = shlex.split(subprocess.check_output(
        ['pkgconf', '--keep-system-cflags', '--keep-system-libs', '--cflags', '--libs', name], text=True))
    exe = Path.cwd() / (name + ('.exe' if windows else ''))
    if windows:
        # cl does not accept pkgconf's Unix-style -l/-L options.
        library = 'ghostty-vt-static.lib' if name.endswith('-static') else 'ghostty-vt.lib'
        defines = ['/DGHOSTTY_STATIC'] if name.endswith('-static') else []
        cmd = ['cl', *defines, '/nologo', str(source), '/I' + str(prefix / 'include'),
               str(prefix / 'lib' / library), 'ntdll.lib', 'kernel32.lib', '/Fe:' + str(exe)]
    else:
        cmd = shlex.split(os.environ.get('CC', 'cc')) + [str(source), '-o', str(exe), *flags,
                                                        '-Wl,-rpath,' + str(prefix / 'lib')]
    subprocess.run(cmd, check=True)
    subprocess.run([str(exe)], check=True)
