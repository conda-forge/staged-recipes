from shutil import rmtree
import tempfile
import conda.base.context
import conda.core.index
import conda.resolve
import conda_build.api
import conda_index.api
import networkx as nx
from compute_build_graph import construct_graph
import argparse
import atexit
import re
import os
from collections import OrderedDict
import sys
import subprocess
import yaml

try:
    from ruamel_yaml import BaseLoader, load
except ImportError:
    from yaml import BaseLoader, load


EXAMPLE_RECIPE_FOLDERS = ["example", "example-new-recipe"]


def get_host_platform():
    from sys import platform
    if platform == "linux" or platform == "linux2":
        return "linux"
    elif platform == "darwin":
        return "osx"
    elif platform == "win32":
        return "win"


def get_config_name(arch):
    platform = get_host_platform()
    return os.environ.get("CONFIG", "{}{}".format(platform, arch))


def build_all(recipes_dir, arch):
    folders = list(filter(lambda d: os.path.isdir(os.path.join(recipes_dir, d)), os.listdir(recipes_dir)))
    if not folders:
        print("Found no recipes to build")
        return

    platform = get_host_platform()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    variant_config_file = os.path.join(script_dir, "{}.yaml".format(get_config_name(arch)))

    has_meta_yaml = False
    has_recipe_yaml = False

    found_cuda = False
    found_centos7 = False
    for folder in folders:
        meta_yaml = os.path.join(recipes_dir, folder, "meta.yaml")
        if os.path.exists(meta_yaml):
            has_meta_yaml = True
            with(open(meta_yaml, "r", encoding="utf-8")) as f:
                text = ''.join(f.readlines())
                if 'cuda' in text:
                    found_cuda = True
                if 'sysroot_linux-64' in text:
                    found_centos7 = True

        recipe_yaml = os.path.join(recipes_dir, folder, "recipe.yaml")
        if os.path.exists(recipe_yaml):
            has_recipe_yaml = True
            with open(recipe_yaml, "r", encoding="utf-8") as f:
                text = "".join(f.readlines())
                if "cuda" in text:
                    found_cuda = True
                if "sysroot_linux-64" in text:
                    found_centos7 = True

        cbc = os.path.join(recipes_dir, folder, "conda_build_config.yaml")
        if os.path.exists(cbc):
            with open(cbc, "r") as f:
                lines = f.readlines()
            pat = re.compile(r"^([^\#]*?)\s+\#\s\[.*(not\s(linux|unix)|(?<!not\s)(osx|win)).*\]\s*$")
            # remove lines with selectors that don't apply to linux, i.e. if they contain
            # "not linux", "not unix", "osx" or "win"; this also removes trailing newlines
            lines = [pat.sub("", x) for x in lines]
            text = "\n".join(lines)
            if platform == 'linux' and ('c_stdlib_version' in text):
                config = load(text, Loader=BaseLoader)
                if 'c_stdlib_version' in config:
                    for version in config['c_stdlib_version']:
                        version = tuple([int(x) for x in version.split('.')])
                        print(f"Found c_stdlib_version for linux: {version=}")
                        found_centos7 |= version == (2, 17)

    if has_meta_yaml and has_recipe_yaml:
        raise ValueError("Mixing meta.yaml and recipe.yaml recipes is not supported")
    if not has_meta_yaml and not has_recipe_yaml:
        raise ValueError("Neither a meta.yaml or a recipe.yaml recipes was found")

    if found_cuda:
        print('##vso[task.setvariable variable=NEED_CUDA;isOutput=true]1')
    if found_centos7:
        os.environ["DEFAULT_LINUX_VERSION"] = "cos7"
        print("Overriding DEFAULT_LINUX_VERSION to be cos7")

    deployment_version = (0, 0)
    sdk_version = (0, 0)
    channel_urls = None
    for folder in folders:
        cbc = os.path.join(recipes_dir, folder, "conda_build_config.yaml")
        if os.path.exists(cbc):
            with open(cbc, "r") as f:
                lines = f.readlines()
            pat = re.compile(r"^([^\#]*?)\s+\#\s\[.*(not\s(osx|unix)|(?<!not\s)(linux|win)).*\]\s*$")
            # remove lines with selectors that don't apply to osx, i.e. if they contain
            # "not osx", "not unix", "linux" or "win"; this also removes trailing newlines
            lines = [pat.sub("", x) for x in lines]
            text = "\n".join(lines)
            if platform == 'osx' and (
                    'MACOSX_DEPLOYMENT_TARGET' in text or
                    'MACOSX_SDK_VERSION' in text or
                    'c_stdlib_version' in text):
                config = load(text, Loader=BaseLoader)

                if 'MACOSX_DEPLOYMENT_TARGET' in config:
                    for version in config['MACOSX_DEPLOYMENT_TARGET']:
                        version = tuple([int(x) for x in version.split('.')])
                        deployment_version = max(deployment_version, version)
                if 'c_stdlib_version' in config:
                    for version in config['c_stdlib_version']:
                        version = tuple([int(x) for x in version.split('.')])
                        print(f"Found c_stdlib_version for osx: {version=}")
                        deployment_version = max(deployment_version, version)
                if 'MACOSX_SDK_VERSION' in config:
                    for version in config['MACOSX_SDK_VERSION']:
                        version = tuple([int(x) for x in version.split('.')])
                        sdk_version = max(sdk_version, deployment_version, version)

            if 'channel_sources' not in text:
                new_channel_urls = ['local', 'conda-forge']
            else:
                config = load(text, Loader=BaseLoader)
                new_channel_urls = ['local'] + config['channel_sources'][0].split(',')
            if channel_urls is None:
                channel_urls = new_channel_urls
            elif channel_urls != new_channel_urls:
                raise ValueError(f'Detected different channel_sources in the recipes: {channel_urls} vs. {new_channel_urls}. Consider submitting them in separate PRs')

    if channel_urls is None:
        channel_urls = ['local', 'conda-forge']

    with open(variant_config_file, 'r') as f:
        variant_text = ''.join(f.readlines())

    if deployment_version != (0, 0):
        deployment_version = '.'.join([str(x) for x in deployment_version])
        print("Overriding MACOSX_DEPLOYMENT_TARGET to be ", deployment_version)
        variant_text += '\nMACOSX_DEPLOYMENT_TARGET:\n'
        variant_text += f'- "{deployment_version}"\n'

    if sdk_version != (0, 0):
        sdk_version = '.'.join([str(x) for x in sdk_version])
        print("Overriding MACOSX_SDK_VERSION to be ", sdk_version)
        variant_text += '\nMACOSX_SDK_VERSION:\n'
        variant_text += f'- "{sdk_version}"\n'

    with open(variant_config_file, 'w') as f:
        f.write(variant_text)

    if platform == "osx" and (sdk_version != (0, 0) or deployment_version != (0, 0)):
        subprocess.run("run_conda_forge_build_setup", shell=True, check=True)

    if 'conda-forge' not in channel_urls:
        raise ValueError('conda-forge needs to be part of channel_sources')
    
    if has_meta_yaml:
        print("Building {} with {}".format(','.join(folders), ','.join(channel_urls)))
        build_folders(recipes_dir, folders, arch, channel_urls)
    elif has_recipe_yaml:
        print(
            "Building {} with {} using rattler-build".format(
                ",".join(folders), ",".join(channel_urls)
            )
        )
        build_folders_rattler_build(recipes_dir, platform, arch, channel_urls)


def get_config(arch, channel_urls):
    exclusive_config_files = [os.path.join(conda.base.context.context.root_prefix,
                                           'conda_build_config.yaml')]
    script_dir = os.path.dirname(os.path.realpath(__file__))
    # since variant builds override recipe/conda_build_config.yaml, see
    # https://github.com/conda/conda-build/blob/3.21.8/conda_build/variants.py#L175-L181
    # we need to make sure not to use variant_configs here, otherwise
    # staged-recipes PRs cannot override anything using the recipe-cbc.
    exclusive_config_file = os.path.join(script_dir, '{}.yaml'.format(
        get_config_name(arch)))
    if os.path.exists(exclusive_config_file):
        exclusive_config_files.append(exclusive_config_file)

    config = conda_build.api.Config(
        arch=arch, exclusive_config_files=exclusive_config_files,
        channel_urls=channel_urls, error_overlinking=True,
    )
    return config


def build_folders(recipes_dir, folders, arch, channel_urls):

    index_path = os.path.join(sys.exec_prefix, 'conda-bld')
    os.makedirs(index_path, exist_ok=True)
    conda_index.api.update_index(index_path)
    index = conda.core.index.get_index(channel_urls=channel_urls)
    conda_resolve = conda.resolve.Resolve(index)

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
        d[G.nodes[node]['meta'].meta_path] = 1

    for recipe in d.keys():
        conda_build.api.build([recipe], config=get_config(arch, channel_urls))


def build_folders_rattler_build(
    recipes_dir: str, platform, arch, channel_urls: list[str]
):
    config = get_config(arch, channel_urls)

    # Remove the example recipes to ensure that they are not also build.
    for example_recipe in EXAMPLE_RECIPE_FOLDERS:
        rmtree(os.path.join(recipes_dir, example_recipe), ignore_errors=True)

    # Determine the locations for the variant config files.
    specs = OrderedDict()
    for f in config.exclusive_config_files:
        specs[f] = conda_build.variants.parse_config_file(
            os.path.abspath(os.path.expanduser(os.path.expandvars(f))), config
        )

    # Combine all the variant config files together
    combined_spec = conda_build.variants.combine_specs(specs, log_output=config.verbose)
    variant_config = yaml.dump(combined_spec)

    # Define the arguments for rattler-build
    args = [
        "rattler-build",
        "build",
        "--recipe-dir",
        recipes_dir,
        "--target-platform",
        f"{platform}-{arch}",
    ]
    for channel_url in channel_urls:
        # Local is automatically added by rattler-build so we just remove it.
        if channel_url != "local":
            args.extend(["-c", channel_url])

    # Construct a temporary file where we write the combined variant config. We can then pass that
    # to rattler-build.
    with tempfile.NamedTemporaryFile(delete=False) as fp:
        fp.write(variant_config.encode("utf-8"))   
        atexit.register(os.unlink, fp.name)

    # Execute rattler-build.
    subprocess.run(args + ["--variant-config", fp.name], check=True)


def check_recipes_in_correct_dir(root_dir, correct_dir):
    from pathlib import Path
    for path in Path(root_dir).rglob('meta.yaml'):
        path = path.absolute().relative_to(root_dir)
        if path.parts[0] == 'build_artifacts':
            # ignore pkg_cache in build_artifacts
            continue
        if path.parts[0] != correct_dir and path.parts[0] != "broken-recipes":
            raise RuntimeError(f"recipe {path.parts} in wrong directory")
        if len(path.parts) != 3:
            raise RuntimeError(f"recipe {path.parts} in wrong directory")


def read_mambabuild(recipes_dir):
    """
    Only use mambabuild if all the recipes require so via
    'conda_build_tool: mambabuild' in 'recipes/<recipe>/conda-forge.yml'
    """
    folders = os.listdir(recipes_dir)
    conda_build_tools = []
    for folder in folders:
        if folder in EXAMPLE_RECIPE_FOLDERS:
            continue
        cf = os.path.join(recipes_dir, folder, "conda-forge.yml")
        if os.path.exists(cf):
            with open(cf, "r") as f:
                cfy = yaml.safe_load(f.read())
            conda_build_tools.append(cfy.get("conda_build_tool", "conda-build"))
        else:
            conda_build_tools.append("conda-build")
    if conda_build_tools:
        return all([tool == "mambabuild" for tool in conda_build_tools])
    return False


def use_mambabuild():
    from boa.cli.mambabuild import prepare
    prepare()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--arch', default='64',
                        help='target architecture (64 or 32)')
    args = parser.parse_args()
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    check_recipes_in_correct_dir(root_dir, "recipes")
    use_mamba = read_mambabuild(os.path.join(root_dir, "recipes"))
    if use_mamba:
      use_mambabuild()
      subprocess.run("conda clean --all --yes", shell=True, check=True)
    build_all(os.path.join(root_dir, "recipes"), args.arch)
