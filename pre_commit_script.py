from __future__ import print_function
import argparse
import hashlib
import os
import shutil
import subprocess as sp
import tempfile
try:
    from urllib.request import urlopen
except ImportError:
    from urllib import urlopen

PACKAGES = ('B-Tax',
            'Tax-Calculator',
            'OG-USA',)
TOP_DIR = os.path.dirname(__file__)
RECIPES_DIR = os.path.join(TOP_DIR, 'recipes')

META_VARIABLES = {
    'B-Tax': {
        'name': "btax",
        'repo_name': "B-Tax",
        'rel_recipe': 'conda.recipe',
    },
    'Tax-Calculator': {
        'name': 'taxcalc',
        'repo_name': 'Tax-Calculator',
        'rel_recipe': 'conda.recipe',
    },
    'OG-USA': {
        'name': 'ogusa',
        'repo_name': 'OG-USA',
        'rel_recipe': os.path.join('Python', 'conda.recipe'),
    }
}

def rm_recipes_dir_contents(package):
    for item in os.listdir(RECIPES_DIR):
        if not package in item:
            continue
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


def get_latest_packages(btax_branch=None, btax_version=None,
                        taxcalc_version=None, taxcalc_branch=None,
                        ogusa_version=None, ogusa_branch=None,
                        git_org='open-source-economics'):
    cmd = ['git', 'clone']
    for package in PACKAGES:
        if package == 'B-Tax':
            if not btax_version:
                print('Not building B-Tax')
                continue
            else:
                version = btax_version
        elif package == 'Tax-Calculator':
            if not taxcalc_version:
                print('Not building Tax-Calculator')
                continue
            else:
                version = taxcalc_version
        elif package == 'OG-USA':
            if not ogusa_version:
                print('Not building OG-USA')
                continue
            else:
                version = ogusa_version
        rm_recipes_dir_contents(package)
        meta_var = META_VARIABLES[package]
        meta_var['git_org'] = git_org
        meta_var['version'] = version
        source_url = 'https://github.com/{git_org}/{repo_name}/archive/{version}.tar.gz'
        source_url = source_url.format(**meta_var)
        meta_var['source_url'] = source_url

        print(source_url)
        tmp = tempfile.mkdtemp()
        try:
            tar_file_contents = urlopen(source_url).read()
            meta_var['sha256'] = hashlib.sha256(tar_file_contents).hexdigest()
            tar_file = os.path.join(tmp, '{version}.tar.gz'.format(**meta_var))
            with open(tar_file, 'wb') as f:
                f.write(tar_file_contents)
            proc_wrapper(['tar', '-xvf', tar_file], cwd=tmp)
            repo_clone = os.path.join(tmp, '{repo_name}-{version}'.format(**meta_var))
            recipe = os.path.join(repo_clone, meta_var['rel_recipe'])
            local_recipe = os.path.join(RECIPES_DIR, package)
            shutil.copytree(recipe, local_recipe)
            meta_yaml = os.path.join(local_recipe, 'meta.yaml')
            with open(meta_yaml) as f:
                contents = [x for x in f.readlines() if not x.lstrip().startswith('#')]
            new_lines = []
            for k, v in meta_var.items():
                line = '% set {0} = "{1}" %'.format(k, v)
                new_lines.append('{' + line + '}')
            contents = "\n".join(new_lines) + '\n' + '\n'.join(contents)
            with open(meta_yaml, 'w') as f:
                f.write(contents)
        finally:
            if os.path.exists(tmp):
                shutil.rmtree(tmp)

def pre_commit_main():
    parser = argparse.ArgumentParser(description='Build conda-forge packages')
    parser.add_argument('--git-org', required=True)
    parser.add_argument('--btax-version', required=True)
    parser.add_argument('--taxcalc-version', required=True)
    parser.add_argument('--ogusa-version', required=True)
    args = parser.parse_args()
    get_latest_packages(**vars(args))


if __name__ == "__main__":
    pre_commit_main()

