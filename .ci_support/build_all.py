import conda_build.conda_interface
import networkx as nx
import conda_build.api
from compute_build_graph import construct_graph
import argparse
import os
from collections import OrderedDict
import sys


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
    if not folders:
        print("Found no recipes to build")
        return
    channel_urls = ['local', 'conda-forge', 'defaults']

    index_path = os.path.join(sys.exec_prefix, 'conda-bld')
    try:
        os.mkdir(index_path)
    except FileExistsError:
        pass
    conda_build.api.update_index(index_path)
    index = conda_build.conda_interface.get_index(channel_urls=channel_urls)
    conda_resolve = conda_build.conda_interface.Resolve(index)

    exclusive_config_file = os.path.join(conda_build.conda_interface.root_dir,
                                         'conda_build_config.yaml')
    platform = get_host_platform()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    variant_config_files = []
    variant_config_file = os.path.join(script_dir, '{}{}.yaml'.format(
        platform, arch))
    if os.path.exists(variant_config_file):
        variant_config_files.append(variant_config_file)

    config = conda_build.api.Config(
        variant_config_files=variant_config_files, arch=arch,
        exclusive_config_file=exclusive_config_file, channel_urls=channel_urls)

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

    conda_build.api.build(list(d.keys()), config=config)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('recipes_dir', default=os.getcwd(),
                        help='Directory where the recipes are')
    parser.add_argument('--arch', default='64',
                        help='target architecture (64 or 32)')
    args = parser.parse_args()
    build_all(args.recipes_dir, args.arch)
