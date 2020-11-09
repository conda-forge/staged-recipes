import glob
import os

pkg_version = os.environ['PKG_VERSION']
prefix = os.environ['PREFIX']

for f in glob.glob(os.path.join(prefix, 'lib', 'emscripten-' + pkg_version, '*.py')):
    # get binary
    bin_name = f[:-3]  # cut .py
    print("Linking up ", bin_name)
    if os.path.exists(bin_name):
        fname = os.path.basename(bin_name)
        dest_file = os.path.join(prefix, 'bin', fname)
        os.symlink(f, dest_file)
