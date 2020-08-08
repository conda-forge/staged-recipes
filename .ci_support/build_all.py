import conda_build.conda_interface
import networkx as nx
import conda_build.api
from compute_build_graph import construct_graph
import argparse
import os
from collections import OrderedDict
import sys

try:
    from ruamel_yaml import safe_load, safe_dump
except ImportError:
    from yaml import safe_load, safe_dump


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

    for folder in folders:
        built = False
        cbc = os.path.join(recipes_dir, folder, "conda_build_config.yaml")
        if os.path.exists(cbc):
            with open(cbc, "r") as f:
                text = ''.join(f.readlines())
            if 'channel_sources' in text:
                specific_config = safe_load(text)
                if "channel_targets" not in specific_config:
                    raise RuntimeError("channel_targets not found in {}".format(folder))
                if "channel_sources" in specific_config:
                    for row in specific_config["channel_sources"]:
                        channels = [c.strip() for c in row.split(",")]
                        if channels != ['conda-forge', 'defaults'] and \
                                channels != ['conda-forge/label/cf201901', 'defaults']:
                            print("Not a standard configuration of channel_sources. Building {} individually.".format(folder))
                            conda_build.api.build([os.path.join(recipes_dir, folder)], config=get_config(arch, channels))
                            built = True
                            break
                if not built:
                    old_comp_folders.append(folder)
                    continue
        if not built:
            new_comp_folders.append(folder)

    if old_comp_folders:
        print("Building {} with conda-forge/label/cf201901".format(','.join(old_comp_folders)))
        channel_urls = ['local', 'conda-forge/label/cf201901', 'defaults']
        build_folders(recipes_dir, old_comp_folders, arch, channel_urls)
    if new_comp_folders:
        print("Building {} with conda-forge/label/main".format(','.join(new_comp_folders)))
        channel_urls = ['local', 'conda-forge', 'defaults']
        build_folders(recipes_dir, new_comp_folders, arch, channel_urls)



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
        if path.parts[0] != correct_dir:
            raise RuntimeError("recipe in wrong directory")
        if len(path.parts) != 3:
            raise RuntimeError("recipe in wrong directory")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--arch', default='64',
                        help='target architecture (64 or 32)')
    args = parser.parse_args()
    root_dir = os.path.dirname(os.path.dirname(__file__))
    check_recipes_in_correct_dir(root_dir, "recipes")
    build_all(os.path.join(root_dir, "recipes"), args.arch)
