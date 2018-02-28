import conda_build.conda_interface
import networkx as nx
import conda_build.api
from compute_build_graph import construct_graph
import argparse
import os

def build_all(recipes_dir, arch):
    folders = os.listdir(recipes_dir)
    if not folders:
        print("Found no recipes to build")
        return
    channel_urls=['local', 'conda-forge', 'defaults']
    index = conda_build.conda_interface.get_index(channel_urls=channel_urls)
    conda_resolve = conda_build.conda_interface.Resolve(index)

    exclusive_config_file = os.path.join(conda_build.conda_interface.root_dir, 'conda_build_config.yaml')
    platform =  get_host_platform()
    variant_config_files = []
    if platform == 'win':
        script_dir = os.path.dirname(os.path.realpath(__file__))
        variant_config_files = [os.path.join(script_dir, 'win{}.yaml'.format(arch))]

    config = conda_build.api.Config(variant_config_files=variant_config_files, arch=arch,
                                    exclusive_config_file=exclusive_config_file,
                                    channel_urls=channel_urls)

    worker={'platform': platform, 'arch': arch, 'label': '{}-{}'.format(platform, arch)}

    G = construct_graph(recipes_dir, worker=worker, run='build', conda_resolve=conda_resolve,
                        folders=folders, config=config)

    order = list(nx.topological_sort(G))
    order.reverse()

    print('Computed that there are {} distributions to build from {} recipes'.format(len(order), len(folders)))
    print("Resolved dependencies, will be built in the following order:")
    print('    '+'\n    '.join(order))

    for node in order:
        conda_build.api.build(G.node[node]['meta'])


def get_host_platform():
    from sys import platform
    if platform == "linux" or platform == "linux2":
        return "linux"
    elif platform == "darwin":
        return "osx"
    elif platform == "win32":
        return "win"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('recipes_dir', default=os.getcwd(), help='Directory where the recipes are')
    parser.add_argument('--arch', default='64', help='target architecture (64 or 32)')
    args = parser.parse_args()
    build_all(args.recipes_dir, args.arch)

