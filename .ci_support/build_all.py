import conda_build.conda_interface
import networkx as nx
import conda_build.api
from compute_build_graph import construct_graph
import argparse
import os
from collections import OrderedDict
import sys
import subprocess

try:
    from ruamel_yaml import BaseLoader, load
except ImportError:
    from yaml import BaseLoader, load


def get_host_platform():
    from sys import platform
    if platform == "linux" or platform == "linux2":
        return "linux"
    elif platform == "darwin":
        return "osx"
    elif platform == "win32":
        return "win"


def build_all(recipes_dir, arch):
    folders = os.listdir(recipes_dir)
    old_comp_folders = []
    new_comp_folders = []
    if not folders:
        print("Found no recipes to build")
        return

    platform = get_host_platform()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    variant_config_file = os.path.join(script_dir, '{}{}.yaml'.format(
        platform, arch))

    found_cuda = False
    found_centos7 = False
    for folder in folders:
        meta_yaml = os.path.join(recipes_dir, folder, "meta.yaml")
        if os.path.exists(meta_yaml):
            with(open(meta_yaml, "r")) as f:
                text = ''.join(f.readlines())
                if 'cuda' in text:
                    found_cuda = True
                if 'sysroot_linux-64' in text:
                    found_centos7 = True
    if found_cuda:
        print('##vso[task.setvariable variable=NEED_CUDA;isOutput=true]1')
    if found_centos7:
        print('##vso[task.setvariable variable=NEED_CENTOS7;isOutput=true]1')

    deployment_version = (0, 0)
    sdk_version = (0, 0)
    for folder in folders:
        cbc = os.path.join(recipes_dir, folder, "conda_build_config.yaml")
        if os.path.exists(cbc):
            with open(cbc, "r") as f:
                text = ''.join(f.readlines())
            if platform == 'osx' and (
                    'MACOSX_DEPLOYMENT_TARGET' in text or
                    'MACOSX_SDK_VERSION' in text):
                config = load(text, Loader=BaseLoader)

                if 'MACOSX_DEPLOYMENT_TARGET' in config:
                    for version in config['MACOSX_DEPLOYMENT_TARGET']:
                        version = tuple([int(x) for x in version.split('.')])
                        deployment_version = max(deployment_version, version)
                if 'MACOSX_SDK_VERSION' in config:
                    for version in config['MACOSX_SDK_VERSION']:
                        version = tuple([int(x) for x in version.split('.')])
                        sdk_version = max(sdk_version, deployment_version, version)

    with open(variant_config_file, 'r') as f:
        variant_text = ''.join(f.readlines())

    if deployment_version != (0, 0):
        deployment_version = '.'.join([str(x) for x in deployment_version])
        print("Overriding MACOSX_DEPLOYMENT_TARGET to be ", deployment_version)
        variant_text += '\nMACOSX_DEPLOYMENT_TARGET:\n'
        variant_text += f'- {deployment_version}\n'

    if sdk_version != (0, 0):
        sdk_version = '.'.join([str(x) for x in sdk_version])
        print("Overriding MACOSX_SDK_VERSION to be ", sdk_version)
        variant_text += '\nMACOSX_SDK_VERSION:\n'
        variant_text += f'- {sdk_version}\n'

    with open(variant_config_file, 'w') as f:
        f.write(variant_text)

    if platform == "osx" and (sdk_version != (0, 0) or deployment_version != (0, 0)):
        subprocess.run("run_conda_forge_build_setup", shell=True, check=True)

    print("Building {} with conda-forge/label/main".format(','.join(folders)))
    channel_urls = ['local', 'conda-forge', 'defaults']
    build_folders(recipes_dir, folders, arch, channel_urls)


def get_config(arch, channel_urls):
    exclusive_config_file = os.path.join(conda_build.conda_interface.root_dir,
                                         'conda_build_config.yaml')
    platform = get_host_platform()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    variant_config_files = []
    variant_config_file = os.path.join(script_dir, '{}{}.yaml'.format(
        platform, arch))
    if os.path.exists(variant_config_file):
        variant_config_files.append(variant_config_file)

    error_overlinking = (get_host_platform() != "win")

    config = conda_build.api.Config(
        variant_config_files=variant_config_files, arch=arch,
        exclusive_config_file=exclusive_config_file, channel_urls=channel_urls,
        error_overlinking=error_overlinking)
    return config


def build_folders(recipes_dir, folders, arch, channel_urls):

    index_path = os.path.join(sys.exec_prefix, 'conda-bld')
    os.makedirs(index_path, exist_ok=True)
    conda_build.api.update_index(index_path)
    index = conda_build.conda_interface.get_index(channel_urls=channel_urls)
    conda_resolve = conda_build.conda_interface.Resolve(index)

    config = get_config(arch, channel_urls)
    platform = get_host_platform()

    worker = {'platform': platform, 'arch': arch,
              'label': '{}-{}'.format(platform, arch)}

    G = construct_graph(recipes_dir, worker=worker, run='build',
                        conda_resolve=conda_resolve, folders=folders,
                        config=config, finalize=False)
    order = list(nx.topological_sort(G))
    order.reverse()

    print('Computed that there are {} distributions to build from {} recipes'
          .format(len(order), len(folders)))
    if not order:
        print('Nothing to do')
        return
    print("Resolved dependencies, will be built in the following order:")
    print('    '+'\n    '.join(order))

    d = OrderedDict()
    for node in order:
        d[G.node[node]['meta'].meta_path] = 1

    for recipe in d.keys():
        conda_build.api.build([recipe], config=get_config(arch, channel_urls))


def check_recipes_in_correct_dir(root_dir, correct_dir):
    from pathlib import Path
    for path in Path(root_dir).rglob('meta.yaml'):
        path = path.absolute().relative_to(root_dir)
        if path.parts[0] != correct_dir:
            raise RuntimeError(f"recipe {path.parts} in wrong directory")
        if len(path.parts) != 3:
            raise RuntimeError(f"recipe {path.parts} in wrong directory")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--arch', default='64',
                        help='target architecture (64 or 32)')
    args = parser.parse_args()
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    check_recipes_in_correct_dir(root_dir, "recipes")
    build_all(os.path.join(root_dir, "recipes"), args.arch)
