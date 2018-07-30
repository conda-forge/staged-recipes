from __future__ import print_function
import os
import shutil
from pathlib import Path
import stat


def set_chmod(file_name):
    # Do a simple chmod +x for a file within python
    st = os.stat(file_name)
    os.chmod(file_name, st.st_mode | stat.S_IXOTH)


def copy_files(src, dst):
    try:
        if (os.path.isfile(src)):
            set_chmod(src)
            shutil.copy(src, dst)
    except FileExistsError:
        pass


def _main():

    prefix_dir_path = Path(os.environ['PREFIX'])
    prefix_bin_dir_path = prefix_dir_path / 'bin'
    recipe_dir_path = Path(os.environ['RECIPE_DIR'])
    scripts_dir_path = recipe_dir_path / 'scripts'
    shutil.copytree(scripts_dir_path, prefix_dir_path / 'scripts')

    # Copy cudatoolkit-dev-post-install.py to $PREFIX/bin
    src = recipe_dir_path / 'cudatoolkit-dev-post-install.py'
    dst = prefix_bin_dir_path
    copy_files(src, dst)


if __name__ == "__main__":
    _main()
