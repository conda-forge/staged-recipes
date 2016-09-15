import argparse
import os
import shutil
import subprocess as sp
import tempfile
from urllib.request import urlopen
import hashlib

PACKAGES = ('http://github.com/PeterDSteinberg/B-Tax',)
TOP_DIR = os.path.dirname(__file__)
RECIPES_DIR = os.path.join(TOP_DIR, 'recipes')

META_VARIABLES = {'B-Tax': {
                    'name': "btax",
                    'repo_name': "B-Tax",
                    'git_org': "PeterDSteinberg",
                    'version':  "0.1.091",
}}

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


def get_latest_packages(btax_branch, btax_version):
    cmd = ['git', 'clone']
    for package in PACKAGES:
        if 'B-Tax' in package:
            meta_var = META_VARIABLES['B-Tax']
            meta_var['version'] = btax_version
            source_url = 'https://github.com/{git_org}/{repo_name}/archive/{version}.tar.gz'
            source_url = source_url.format(**meta_var)
            meta_var['source_url'] = source_url

            print(source_url)
            with urlopen(source_url) as f:
                tar_file = f.read()
                meta_var['sha256'] = hashlib.sha256(tar_file).hexdigest()
        else:
            raise NotImplementedError("Add more keys to the META_VARIABLES global")
        args = cmd + [package]

        tmp = tempfile.mkdtemp()
        try:
            proc_wrapper(args, tmp)
            pdir = package.split('/')[-1]
            repo_clone = os.path.join(tmp, pdir)
            proc_wrapper(['git', 'fetch', '--all'], repo_clone)
            proc_wrapper(['git', 'checkout', btax_branch], repo_clone)
            recipe = os.path.join(repo_clone, 'conda.recipe')
            shutil.copytree(recipe, os.path.join(RECIPES_DIR, pdir))
            meta_yaml = os.path.join(RECIPES_DIR, pdir, 'meta.yaml')
            with open(meta_yaml) as f:
                contents = f.read()
            new_lines = []
            for k, v in meta_var.items():
                line = '% set {0} = "{1}" %'.format(k, v)
                new_lines.append('{' + line + '}')
            contents = "\n".join(new_lines) + '\n' + contents
            with open(meta_yaml, 'w') as f:
                f.write(contents)
        finally:
            if os.path.exists(tmp):
                shutil.rmtree(tmp)

def pre_commit_main():
    parser = argparse.ArgumentParser(description='Build conda-forge packages')
    parser.add_argument('--btax-branch', required=True)
    parser.add_argument('--btax-version', required=True)
    args = parser.parse_args()
    rm_recipes_dir_contents()
    get_latest_packages(args.btax_branch, args.btax_version)


if __name__ == "__main__":
    pre_commit_main()

