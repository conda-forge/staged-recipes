#!/usr/bin/env python3
"""
Diagnostic script to explore hydra-haskell installation and library availability.
"""

import sys
import pathlib
import os
import subprocess

def main():
    print('=== HYDRA-HASKELL DIAGNOSTIC ===')
    print()

    # Check if we're on Windows - this package should not be built on Windows
    if os.name == 'nt' or sys.platform.startswith('win'):
        print('ERROR: hydra-haskell should not be built on Windows!')
        print('       GHC is not available as a conda package on Windows.')
        print('       This package is marked as skip: win in the recipe.')
        sys.exit(1)

    print('Python version:', sys.version)
    print('Python executable:', sys.executable)
    print('Current working directory:', os.getcwd())
    print()

    print('Environment variables:')
    for var in ['PREFIX', 'CONDA_PREFIX', 'BUILD_PREFIX', 'HOST', 'RECIPE_DIR']:
        value = os.environ.get(var, 'NOT SET')
        print(f'  {var}: {value}')
    print()

    print('GHC version check:')
    try:
        result = subprocess.run(['ghc', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print('[+] GHC is available:')
            print(f'  {result.stdout.strip()}')
        else:
            print(f'[-] GHC version check failed: {result.stderr}')
    except Exception as e:
        print(f'[-] Error running ghc --version: {e}')
    print()

    print('Stack version check:')
    try:
        result = subprocess.run(['stack', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print('[+] Stack is available:')
            print(f'  {result.stdout.strip()}')
        else:
            print(f'[-] Stack version check failed: {result.stderr}')
    except Exception as e:
        print(f'[-] Error running stack --version: {e}')
    print()

    print('Searching for hydra-haskell installation:')
    search_roots = []

    # Add environment-based roots
    for var in ['PREFIX', 'CONDA_PREFIX']:
        value = os.environ.get(var)
        if value and os.path.exists(value):
            search_roots.append(pathlib.Path(value))

    hydra_haskell_found = False

    for root in search_roots:
        print(f'Searching in: {root}')
        try:
            # Look for hydra-haskell lib directory
            hydra_lib_dir = root / 'lib' / 'hydra-haskell'
            if hydra_lib_dir.exists():
                hydra_haskell_found = True
                print(f'  [+] Found hydra-haskell lib: {hydra_lib_dir}')

                # Check Haskell library files
                lib_files = list(hydra_lib_dir.rglob('*'))
                hs_files = [f for f in lib_files if f.suffix in ['.hi', '.o', '.a', '.so']]
                print(f'  Haskell library files found ({len(hs_files)}):')
                for hf in hs_files[:10]:  # Show first 10
                    size = hf.stat().st_size if hf.is_file() else 'dir'
                    rel_path = hf.relative_to(hydra_lib_dir)
                    print(f'    {rel_path} ({size} bytes)')
                if len(hs_files) > 10:
                    print(f'    ... and {len(hs_files) - 10} more files')

                # Check for specific expected directories/files
                expected_dirs = ['Hydra', 'hydra']
                for expected in expected_dirs:
                    matching_dirs = list(hydra_lib_dir.rglob(expected))
                    if matching_dirs:
                        print(f'    [+] Found {expected}-related directories: {[d.relative_to(hydra_lib_dir) for d in matching_dirs[:3]]}')
                    else:
                        print(f'    - No {expected}-related directories found')

            # Look for hydra-haskell executable
            bin_dir = root / 'bin'
            if bin_dir.exists():
                hydra_haskell_exe = bin_dir / 'hydra-haskell'
                if hydra_haskell_exe.exists():
                    print(f'  [+] Found hydra-haskell executable: {hydra_haskell_exe}')
                    print(f'    Permissions: {oct(hydra_haskell_exe.stat().st_mode)[-3:]}')
                    print(f'    Size: {hydra_haskell_exe.stat().st_size} bytes')

                    # Try to read first few lines
                    try:
                        with open(hydra_haskell_exe, 'r') as f:
                            first_lines = f.read(200)
                        print(f'    Content preview: {repr(first_lines)}')
                    except Exception as e:
                        print(f'    Could not read content (binary?): {e}')
                else:
                    print(f'  [-] hydra-haskell executable not found in {bin_dir}')

            # Look for Windows batch file
            scripts_dir = root / 'Scripts'
            if scripts_dir.exists():
                hydra_haskell_bat = scripts_dir / 'hydra-haskell.bat'
                if hydra_haskell_bat.exists():
                    print(f'  [+] Found hydra-haskell.bat: {hydra_haskell_bat}')
                    print(f'    Size: {hydra_haskell_bat.stat().st_size} bytes')

        except Exception as e:
            print(f'  Error searching {root}: {e}')

    if not hydra_haskell_found:
        print('WARNING: No hydra-haskell installation found!')
    print()

    print('Testing hydra-haskell command availability:')
    try:
        # First check if command exists in PATH
        result = subprocess.run(['which', 'hydra-haskell'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f'[+] hydra-haskell found in PATH: {result.stdout.strip()}')

            # Try to run it with --help
            try:
                result2 = subprocess.run(['hydra-haskell', '--help'],
                                       capture_output=True, text=True, timeout=10)
                if result2.returncode == 0:
                    print('[+] hydra-haskell --help works:')
                    lines = result2.stdout.strip().split('\n')[:5]  # First 5 lines
                    for line in lines:
                        print(f'    {line}')
                else:
                    print(f'[-] hydra-haskell --help failed: {result2.stderr}')
            except subprocess.TimeoutExpired:
                print('[-] hydra-haskell --help timed out')
            except Exception as e:
                print(f'[-] Error running hydra-haskell --help: {e}')
        else:
            print('[-] hydra-haskell not found in PATH')
            # Try whereis on Linux
            result2 = subprocess.run(['whereis', 'hydra-haskell'], capture_output=True, text=True)
            if result2.returncode == 0:
                print(f'  whereis result: {result2.stdout.strip()}')
    except FileNotFoundError:
        # On Windows, try 'where' instead of 'which'
        try:
            result = subprocess.run(['where', 'hydra-haskell'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f'[+] hydra-haskell found: {result.stdout.strip()}')
            else:
                print('[-] hydra-haskell not found with where command')
        except Exception as e:
            print(f'[-] Could not check command availability: {e}')
    except Exception as e:
        print(f'[-] Error checking command availability: {e}')
    print()

    print('GHC package database check:')
    try:
        result = subprocess.run(['ghc-pkg', 'list'], capture_output=True, text=True)
        if result.returncode == 0:
            packages = result.stdout.strip()
            hydra_packages = [line for line in packages.split('\n') if 'hydra' in line.lower()]
            if hydra_packages:
                print('[+] Found Hydra-related packages in GHC package database:')
                for pkg in hydra_packages:
                    print(f'    {pkg.strip()}')
            else:
                print('[-] No Hydra-related packages found in GHC package database')
                # Show a sample of packages
                lines = packages.split('\n')[:10]
                print('  Sample packages:')
                for line in lines:
                    if line.strip():
                        print(f'    {line.strip()}')
        else:
            print(f'[-] ghc-pkg list failed: {result.stderr}')
    except Exception as e:
        print(f'[-] Error running ghc-pkg list: {e}')
    print()

    print('Checking build vs test environment:')
    if os.environ.get('BUILD_PREFIX'):
        print('  [+] BUILD_PREFIX set - this appears to be build environment')
        build_prefix = pathlib.Path(os.environ['BUILD_PREFIX'])
        print(f'    BUILD_PREFIX: {build_prefix}')
    else:
        print('  [-] BUILD_PREFIX not set - this appears to be test environment')

    if os.environ.get('PREFIX'):
        prefix = pathlib.Path(os.environ['PREFIX'])
        print(f'  PREFIX: {prefix}')
        if prefix.exists():
            lib_dirs = list(prefix.glob('lib/*'))
            haskell_related = [d for d in lib_dirs if 'haskell' in d.name.lower() or 'hydra' in d.name.lower() or 'ghc' in d.name.lower()]
            if haskell_related:
                print(f'    Haskell/Hydra related lib dirs: {[d.name for d in haskell_related]}')
    print()

    print('PATH environment check:')
    path_dirs = os.environ.get('PATH', '').split(os.pathsep)
    print(f'PATH has {len(path_dirs)} directories')
    relevant_paths = [p for p in path_dirs if any(keyword in p.lower() for keyword in ['conda', 'bin', 'script', 'ghc', 'stack'])]
    print('Relevant PATH entries:')
    for p in relevant_paths[:10]:  # Show first 10
        print(f'  {p}')
    print()

    print('Haskell module search paths:')
    for root in search_roots:
        haskell_lib_paths = list(root.glob('lib/ghc*/'))
        if haskell_lib_paths:
            print(f'GHC library paths in {root}:')
            for hlp in haskell_lib_paths:
                print(f'  {hlp}')
                package_dirs = list(hlp.glob('*/'))[:5]  # First 5
                for pd in package_dirs:
                    print(f'    {pd.name}')
    print()

    print()
    print('=== END DIAGNOSTIC ===')

if __name__ == '__main__':
    main()
