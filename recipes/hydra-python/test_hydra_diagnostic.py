#!/usr/bin/env python3
"""
Diagnostic script to explore hydra module structure and import issues.
"""

import sys
import pathlib
import importlib
import importlib.util
import os

def main():
    print('=== HYDRA MODULE DIAGNOSTIC ===')
    print()

    print('Python version:', sys.version)
    print('Python executable:', sys.executable)
    print('Current working directory:', os.getcwd())
    print()

    print('Environment variables:')
    for var in ['SRC_DIR', 'PREFIX', 'CONDA_PREFIX', 'BUILD_PREFIX', 'HOST', 'RECIPE_DIR']:
        value = os.environ.get(var, 'NOT SET')
        print(f'  {var}: {value}')
    print()

    print('Python path:')
    for i, p in enumerate(sys.path):
        print(f'  {i}: {p}')
    print()

    print('Searching for hydra files across the filesystem:')
    search_roots = []

    # Add environment-based roots
    for var in ['PREFIX', 'CONDA_PREFIX', 'BUILD_PREFIX', 'SRC_DIR']:
        value = os.environ.get(var)
        if value and os.path.exists(value):
            search_roots.append(pathlib.Path(value))

    # Add Python path roots
    for path_str in sys.path:
        path = pathlib.Path(path_str)
        if path.exists():
            search_roots.append(path)

    # Remove duplicates and search for hydra
    unique_roots = list(set(search_roots))
    hydra_found = False

    for root in unique_roots:
        print(f'Searching in: {root}')
        try:
            # Look for hydra directories
            hydra_dirs = list(root.rglob('hydra'))
            for hdir in hydra_dirs:
                if hdir.is_dir():
                    hydra_found = True
                    print(f'  [+] Found hydra dir: {hdir}')

                    # Check contents
                    contents = list(hdir.iterdir())[:15]
                    print(f'    Contents ({len(contents)}): {[c.name for c in contents]}')

                    # Check for __init__.py
                    init_py = hdir / '__init__.py'
                    if init_py.exists():
                        print(f'    __init__.py: exists ({init_py.stat().st_size} bytes)')
                        try:
                            content = init_py.read_text()[:100]
                            print(f'    __init__.py preview: {repr(content)}')
                        except Exception as e:
                            print(f'    __init__.py read error: {e}')
                    else:
                        print('    __init__.py: NOT FOUND')

                    # Check if it's in site-packages
                    if 'site-packages' in str(hdir):
                        print('    [+] This is in site-packages!')
        except Exception as e:
            print(f'  Error searching {root}: {e}')

    if not hydra_found:
        print('WARNING: No hydra directories found anywhere!')
    print()

    print('Checking site-packages specifically:')
    for path_str in sys.path:
        path = pathlib.Path(path_str)
        if path.name == 'site-packages' and path.exists():
            print(f'Site-packages: {path}')
            all_contents = list(path.iterdir())[:20]
            print(f'  All contents: {[c.name for c in all_contents]}')

            hydra_paths = list(path.glob('hydra*'))
            if hydra_paths:
                for hp in hydra_paths:
                    print(f'  Found hydra-related: {hp}')
            else:
                print('  No hydra directories found')
    print()

    print('Attempting to find hydra module spec:')
    try:
        spec = importlib.util.find_spec('hydra')
        if spec:
            print(f'[+] Module spec found: {spec}')
            print(f'  Origin: {spec.origin}')
            print(f'  Submodule search locations: {spec.submodule_search_locations}')

            # Try to actually import it
            try:
                hydra_module = importlib.import_module('hydra')
                print(f'[+] Successfully imported hydra: {hydra_module}')
                print(f'  Hydra __file__: {getattr(hydra_module, "__file__", "N/A")}')
                print(f'  Hydra __path__: {getattr(hydra_module, "__path__", "N/A")}')
            except Exception as e:
                print(f'[-] Import failed: {e}')
                import traceback
                traceback.print_exc()
        else:
            print('[-] No module spec found for hydra')
    except Exception as e:
        print(f'[-] Error finding spec: {e}')
        import traceback
        traceback.print_exc()
    print()

    print('Attempting to explore hydra submodules:')
    submodules = [
        'hydra.lib',
        'hydra.lib.chars',
        'hydra.lib.equality',
        'hydra.lib.lists',
        'hydra.lib.maps',
        'hydra.tools'
    ]

    for submod in submodules:
        try:
            spec = importlib.util.find_spec(submod)
            if spec:
                print(f'[+] {submod}: spec found at {spec.origin}')
                try:
                    module = importlib.import_module(submod)
                    print(f'  [+] Successfully imported: {module}')
                    print(f'    __file__: {getattr(module, "__file__", "N/A")}')
                except Exception as e:
                    print(f'  [-] Import failed: {e}')
            else:
                print(f'[-] {submod}: spec not found')
        except Exception as e:
            print(f'[-] {submod}: error finding spec: {e}')
    print()

    print('Checking if we are in build vs test environment:')
    if os.environ.get('BUILD_PREFIX'):
        print('  [+] BUILD_PREFIX set - this appears to be build environment')
        build_prefix = pathlib.Path(os.environ['BUILD_PREFIX'])
        print(f'    BUILD_PREFIX: {build_prefix}')
        if build_prefix.exists():
            build_site_packages = list(build_prefix.glob('lib/python*/site-packages'))
            for bsp in build_site_packages:
                hydra_build = bsp / 'hydra'
                print(f'    Build site-packages hydra: {hydra_build} (exists: {hydra_build.exists()})')
    else:
        print('  [-] BUILD_PREFIX not set - this appears to be test environment')

    print('Pip list in current environment:')
    try:
        import subprocess
        result = subprocess.run([sys.executable, '-m', 'pip', 'list'], capture_output=True, text=True)
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            hydra_lines = [line for line in lines if 'hydra' in line.lower()]
            if hydra_lines:
                print('  Hydra-related packages:')
                for line in hydra_lines:
                    print(f'    {line}')
            else:
                print('  No hydra-related packages found in pip list')
        else:
            print(f'  pip list failed: {result.stderr}')
    except Exception as e:
        print(f'  Error running pip list: {e}')
    print()

    print()
    print('=== END DIAGNOSTIC ===')

if __name__ == '__main__':
    main()
