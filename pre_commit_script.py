import argparse
import os
import shutil
import subprocess as sp
import tempfile

PACKAGES = ('http://github.com/PeterDSteinberg/B-Tax',)
TOP_DIR = os.path.dirname(__file__)
RECIPES_DIR = os.path.join(TOP_DIR, 'recipes')


def rm_recipes_dir_contents():
    for item in os.listdir(RECIPES_DIR):
        item = os.path.join(RECIPES_DIR, item)
        if os.path.isfile(item):
            os.remove(item)
        else:
            shutil.rmtree(item)
def proc_wrapper(args, cwd):
    print('Run {}'.format(args))
    proc = sp.Popen(args,
                    cwd=cwd,
                    stdout=sp.PIPE,
                    stderr=sp.STDOUT)
    while proc.poll() is None:
        print(proc.stdout.readline().decode(),end='')
    print(proc.stdout.read().decode())
    if proc.poll():
        raise ValueError('Subprocess has bad return code {}'.format(proc.poll()))


def get_latest_packages(branch):
    cmd = ['git', 'clone']
    for package in PACKAGES:
        args = cmd + [package]

        tmp = tempfile.mkdtemp()
        try:
            proc_wrapper(args, tmp)
            pdir = package.split('/')[-1]
            repo_clone = os.path.join(tmp, pdir)
            proc_wrapper(['git', 'fetch', '--all'], repo_clone)
            proc_wrapper(['git', 'checkout', branch], repo_clone)
            recipe = os.path.join(repo_clone, 'conda.recipe')
            shutil.copytree(recipe, os.path.join(RECIPES_DIR, pdir))
        finally:
            if os.path.exists(tmp):
                shutil.rmtree(tmp)

def pre_commit_main():
    parser = argparse.ArgumentParser(description='Build conda-forge packages')
    parser.add_argument('branch')
    args = parser.parse_args()
    rm_recipes_dir_contents()
    get_latest_packages(args.branch)


if __name__ == "__main__":
    pre_commit_main()

