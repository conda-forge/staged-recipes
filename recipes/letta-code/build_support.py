"""Prepare npm metadata and build native add-ons against conda libraries."""
import ast
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

prefix = Path(os.environ['PREFIX'])
build = Path(os.environ['BUILD_PREFIX'])
src = Path(os.environ['SRC_DIR'])
modules = 'node_modules' if os.name == 'nt' else 'lib/node_modules'
node = shutil.which('node')


def prepare():
    # The optional Cursor integration distributes proprietary prebuilt SDKs.
    for filename in ('package.json', 'npm-shrinkwrap.json'):
        path = Path(filename)
        data = json.loads(path.read_text())
        data.get('dependencies', {}).pop('@cursor/sdk', None)
        packages = data.get('packages', {})
        packages.get('', {}).get('dependencies', {}).pop('@cursor/sdk', None)
        for name in list(packages):
            if name.startswith('node_modules/@cursor/'):
                del packages[name]
        path.write_text(json.dumps(data, indent=2) + '\n')


def clean(root):
    for manifest in list(root.rglob('package.json')):
        if not manifest.is_file():
            continue
        data = json.loads(manifest.read_text(encoding='utf-8'))
        name = data.get('name', '')
        if name.startswith(('@vscode/ripgrep', '@img/sharp-', '@janhapke/')):
            shutil.rmtree(manifest.parent)


def configure_pty(path, windows):
    for directory in ('prebuilds', 'third_party'):
        shutil.rmtree(path / directory, ignore_errors=True)
    if windows:
        # Supported Node.js versions require Windows with built-in ConPTY.
        # Build the ConPTY add-ons, not the legacy winpty backend or bundled
        # OpenConsole.exe/conpty.dll. Keep the upstream /guard:cf flags.
        gyp = path / 'binding.gyp'
        data = ast.literal_eval(gyp.read_text())
        targets = data['conditions'][0][1]['targets']
        data['conditions'][0][1]['targets'] = [
            target for target in targets
            if target['target_name'] in ('conpty', 'conpty_console_list')
        ]
        # Use the conda toolchain's CRT; the optional Spectre CRT is not needed.
        data['target_defaults']['conditions'][0][1].pop('msvs_configuration_attributes', None)
        gyp.write_text(repr(data))


def configure_sharp(path, prefix, windows):
    libvips = path / 'dist/libvips.cjs'
    source = libvips.read_text()
    old = 'getBrewPkgConfigPath(),\n      getPkgConfigPath(),\n      '
    assert old in source, 'sharp pkg-config lookup changed'
    libvips.write_text(source.replace(old, ''))
    if windows:
        # Conda's vips-cpp DLL uses the same MSVC ABI. Link its import libraries
        # directly instead of compiling the npm vendor copy of libvips C++.
        gyp = path / 'src/binding.gyp'
        data = ast.literal_eval(gyp.read_text())
        library = prefix / 'Library'
        data['variables']['sharp_libvips_include_dir'] = (library / 'include').as_posix()
        data['variables']['sharp_libvips_lib_dir'] = (library / 'lib').as_posix()
        data['variables']['sharp_libvips_cplusplus_dir'] = ''
        sharp = next(target for target in data['targets'] if target['target_name'].startswith('sharp-'))
        sharp['dependencies'] = [value for value in sharp['dependencies'] if not value.startswith('libvips-cpp-')]
        windows = sharp['conditions'][0][2]['conditions'][0][1]
        windows['link_settings']['libraries'] = [
            'vips-cpp.lib', 'vips.lib', 'glib-2.0.lib', 'gobject-2.0.lib', 'gio-2.0.lib',
        ]
        data['targets'] = [sharp]
        gyp.write_text(repr(data))


def native(root):
    # Invoke conda's build dependency directly, including on Windows where
    # the command-line launcher is a .cmd file.
    node_gyp = build / modules / 'node-gyp/bin/node-gyp.js'
    env = dict(os.environ, SHARP_FORCE_GLOBAL_LIBVIPS='1')
    for manifest in root.rglob('package.json'):
        name = json.loads(manifest.read_text(encoding='utf-8')).get('name')
        if name not in ('node-pty', 'sharp'):
            continue
        path = manifest.parent
        if name == 'node-pty':
            configure_pty(path, windows=os.name == 'nt')
            cwd = path
        else:
            configure_sharp(path, prefix, windows=os.name == 'nt')
            cwd = path / 'src'
        command = [node, str(node_gyp), 'rebuild']
        if os.name == 'nt':
            # Windows nodejs packages omit headers and node.lib. Let node-gyp
            # fetch and checksum the files for the selected Node.js version.
            command += ['--devdir', str(src / 'node-headers'), '--msvs_version=2022']
        else:
            command += ['--nodedir', str(prefix)]
        subprocess.run(command, cwd=cwd, env=env, check=True)
        if name == 'node-pty' and os.name != 'nt':
            subprocess.run([node, 'scripts/post-install.js'], cwd=path, check=True)
        if name == 'sharp':
            binary, = (cwd / 'build/Release').glob('sharp-*.node')
            version = json.loads(manifest.read_text())['version']
            package = binary.stem.removesuffix('-' + version)
            destination = path.parent / '@img' / package
            destination.mkdir(parents=True)
            # A JS forwarding module works on Windows without symlink privileges
            # and loads the same .node file for the bundled and external loaders.
            (destination / 'sharp.node.js').write_text(
                f"module.exports = require('../../sharp/src/build/Release/{binary.name}');\n"
            )
        shutil.rmtree(cwd / 'build/Release/obj.target', ignore_errors=True)
        # These Windows-only source helpers are not used at runtime.
        if name == 'node-pty':
            shutil.rmtree(path / 'deps', ignore_errors=True)


if sys.argv[1] == 'prepare':
    prepare()
elif sys.argv[1] == 'native':
    root = Path(sys.argv[2])
    clean(root)
    native(root)
else:
    raise ValueError(sys.argv[1])
