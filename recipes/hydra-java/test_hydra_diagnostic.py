#!/usr/bin/env python3
"""
Diagnostic script to explore hydra-java installation and JAR file availability.
"""

import sys
import pathlib
import os
import subprocess

def main():
    print('=== HYDRA-JAVA DIAGNOSTIC ===')
    print()

    print('Python version:', sys.version)
    print('Python executable:', sys.executable)
    print('Current working directory:', os.getcwd())
    print()

    print('Environment variables:')
    for var in ['PREFIX', 'CONDA_PREFIX', 'BUILD_PREFIX', 'HOST', 'RECIPE_DIR']:
        value = os.environ.get(var, 'NOT SET')
        print(f'  {var}: {value}')
    print()

    print('Java version check:')
    try:
        result = subprocess.run(['java', '-version'], capture_output=True, text=True)
        if result.returncode == 0:
            print('✓ Java is available:')
            for line in result.stderr.strip().split('\n'):
                print(f'  {line}')
        else:
            print(f'✗ Java version check failed: {result.stderr}')
    except Exception as e:
        print(f'✗ Error running java -version: {e}')
    print()

    print('Searching for hydra-java installation:')
    search_roots = []

    # Add environment-based roots
    for var in ['PREFIX', 'CONDA_PREFIX']:
        value = os.environ.get(var)
        if value and os.path.exists(value):
            search_roots.append(pathlib.Path(value))

    hydra_java_found = False

    for root in search_roots:
        print(f'Searching in: {root}')
        try:
            # Look for hydra-java lib directory
            hydra_lib_dir = root / 'lib' / 'hydra-java'
            if hydra_lib_dir.exists():
                hydra_java_found = True
                print(f'  ✓ Found hydra-java lib: {hydra_lib_dir}')

                # Check JAR files
                jar_files = list(hydra_lib_dir.glob('*.jar'))
                print(f'  JAR files found ({len(jar_files)}):')
                for jar in jar_files:
                    size = jar.stat().st_size
                    print(f'    {jar.name} ({size} bytes)')

                # Check for specific expected JARs
                expected_jars = ['hydra-java', 'hydra-core', 'hydra-ext']
                for expected in expected_jars:
                    matching_jars = [j for j in jar_files if expected in j.name.lower()]
                    if matching_jars:
                        print(f'    ✓ Found {expected}-related JARs: {[j.name for j in matching_jars]}')
                    else:
                        print(f'    - No {expected}-related JARs found')

            # Look for hydra-java executable
            bin_dir = root / 'bin'
            if bin_dir.exists():
                hydra_java_exe = bin_dir / 'hydra-java'
                if hydra_java_exe.exists():
                    print(f'  ✓ Found hydra-java executable: {hydra_java_exe}')
                    print(f'    Permissions: {oct(hydra_java_exe.stat().st_mode)[-3:]}')
                    print(f'    Size: {hydra_java_exe.stat().st_size} bytes')

                    # Try to read first few lines
                    try:
                        with open(hydra_java_exe, 'r') as f:
                            first_lines = f.read(200)
                        print(f'    Content preview: {repr(first_lines)}')
                    except Exception as e:
                        print(f'    Could not read content: {e}')
                else:
                    print(f'  ✗ hydra-java executable not found in {bin_dir}')

            # Look for Windows batch file
            scripts_dir = root / 'Scripts'
            if scripts_dir.exists():
                hydra_java_bat = scripts_dir / 'hydra-java.bat'
                if hydra_java_bat.exists():
                    print(f'  ✓ Found hydra-java.bat: {hydra_java_bat}')
                    print(f'    Size: {hydra_java_bat.stat().st_size} bytes')

        except Exception as e:
            print(f'  Error searching {root}: {e}')

    if not hydra_java_found:
        print('WARNING: No hydra-java installation found!')
    print()

    print('Testing hydra-java command availability:')
    try:
        # First check if command exists in PATH
        result = subprocess.run(['which', 'hydra-java'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f'✓ hydra-java found in PATH: {result.stdout.strip()}')
        else:
            print('✗ hydra-java not found in PATH')
            # Try whereis on Linux
            result2 = subprocess.run(['whereis', 'hydra-java'], capture_output=True, text=True)
            if result2.returncode == 0:
                print(f'  whereis result: {result2.stdout.strip()}')
    except FileNotFoundError:
        # On Windows, try 'where' instead of 'which'
        try:
            result = subprocess.run(['where', 'hydra-java'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f'✓ hydra-java found: {result.stdout.strip()}')
            else:
                print('✗ hydra-java not found with where command')
        except Exception as e:
            print(f'✗ Could not check command availability: {e}')
    except Exception as e:
        print(f'✗ Error checking command availability: {e}')
    print()

    print('Testing classpath construction:')
    for root in search_roots:
        hydra_lib_dir = root / 'lib' / 'hydra-java'
        if hydra_lib_dir.exists():
            print(f'Constructing classpath from: {hydra_lib_dir}')
            jar_files = list(hydra_lib_dir.glob('*.jar'))
            if jar_files:
                classpath = ':'.join(str(jar) for jar in jar_files)
                print(f'  Classpath length: {len(classpath)} characters')
                print(f'  First 200 chars: {classpath[:200]}')

                # Test if Java can load the classpath
                try:
                    result = subprocess.run(['java', '-cp', classpath, '-version'],
                                          capture_output=True, text=True, timeout=10)
                    if result.returncode == 0:
                        print('  ✓ Java can load the classpath successfully')
                    else:
                        print(f'  ✗ Java classpath test failed: {result.stderr}')
                except subprocess.TimeoutExpired:
                    print('  ✗ Java classpath test timed out')
                except Exception as e:
                    print(f'  ✗ Error testing classpath: {e}')
            else:
                print('  ✗ No JAR files found for classpath')
            break
    print()

    print('Checking build vs test environment:')
    if os.environ.get('BUILD_PREFIX'):
        print('  ✓ BUILD_PREFIX set - this appears to be build environment')
        build_prefix = pathlib.Path(os.environ['BUILD_PREFIX'])
        print(f'    BUILD_PREFIX: {build_prefix}')
    else:
        print('  ✗ BUILD_PREFIX not set - this appears to be test environment')

    if os.environ.get('PREFIX'):
        prefix = pathlib.Path(os.environ['PREFIX'])
        print(f'  PREFIX: {prefix}')
        if prefix.exists():
            lib_dirs = list(prefix.glob('lib/*'))
            java_related = [d for d in lib_dirs if 'java' in d.name.lower() or 'hydra' in d.name.lower()]
            if java_related:
                print(f'    Java/Hydra related lib dirs: {[d.name for d in java_related]}')
    print()

    print('PATH environment check:')
    path_dirs = os.environ.get('PATH', '').split(os.pathsep)
    print(f'PATH has {len(path_dirs)} directories')
    relevant_paths = [p for p in path_dirs if any(keyword in p.lower() for keyword in ['conda', 'bin', 'script'])]
    print('Relevant PATH entries:')
    for p in relevant_paths[:10]:  # Show first 10
        print(f'  {p}')
    print()

    print()
    print('=== END DIAGNOSTIC ===')

if __name__ == '__main__':
    main()
