#!/usr/bin/env python3
"""
Diagnostic script to explore hydra-scala installation and JAR file availability.
"""

import sys
import pathlib
import os
import subprocess
import glob

def main():
    print('=== HYDRA-SCALA DIAGNOSTIC ===')
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

    print('Searching for hydra-scala installation:')
    search_roots = []

    # Add environment-based roots
    for var in ['PREFIX', 'CONDA_PREFIX']:
        value = os.environ.get(var)
        if value and os.path.exists(value):
            search_roots.append(pathlib.Path(value))

    hydra_scala_found = False

    for root in search_roots:
        print(f'Searching in: {root}')
        try:
            # Look for hydra-scala lib directory
            hydra_lib_dir = root / 'lib' / 'hydra-scala'
            if hydra_lib_dir.exists():
                hydra_scala_found = True
                print(f'  ✓ Found hydra-scala lib: {hydra_lib_dir}')

                # Check JAR files
                jar_files = list(hydra_lib_dir.glob('*.jar'))
                print(f'  JAR files found ({len(jar_files)}):')
                for jar in jar_files:
                    size = jar.stat().st_size
                    print(f'    {jar.name} ({size} bytes)')

                # Check for specific expected JARs
                expected_jars = ['hydra-scala', 'scala-library', 'hydra']
                for expected in expected_jars:
                    matching_jars = [j for j in jar_files if expected in j.name.lower()]
                    if matching_jars:
                        print(f'    ✓ Found {expected}-related JARs: {[j.name for j in matching_jars]}')
                    else:
                        print(f'    - No {expected}-related JARs found')

            # Look for hydra-scala executable
            bin_dir = root / 'bin'
            if bin_dir.exists():
                hydra_scala_exe = bin_dir / 'hydra-scala'
                if hydra_scala_exe.exists():
                    print(f'  ✓ Found hydra-scala executable: {hydra_scala_exe}')
                    print(f'    Permissions: {oct(hydra_scala_exe.stat().st_mode)[-3:]}')
                    print(f'    Size: {hydra_scala_exe.stat().st_size} bytes')

                    # Try to read first few lines
                    try:
                        with open(hydra_scala_exe, 'r') as f:
                            first_lines = f.read(200)
                        print(f'    Content preview: {repr(first_lines)}')
                    except Exception as e:
                        print(f'    Could not read content: {e}')
                else:
                    print(f'  ✗ hydra-scala executable not found in {bin_dir}')

            # Look for Windows batch file
            scripts_dir = root / 'Scripts'
            if scripts_dir.exists():
                hydra_scala_bat = scripts_dir / 'hydra-scala.bat'
                if hydra_scala_bat.exists():
                    print(f'  ✓ Found hydra-scala.bat: {hydra_scala_bat}')
                    print(f'    Size: {hydra_scala_bat.stat().st_size} bytes')

        except Exception as e:
            print(f'  Error searching {root}: {e}')

    if not hydra_scala_found:
        print('WARNING: No hydra-scala installation found!')
    print()

    print('Testing hydra-scala command availability:')
    try:
        # First check if command exists in PATH
        result = subprocess.run(['which', 'hydra-scala'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f'✓ hydra-scala found in PATH: {result.stdout.strip()}')
        else:
            print('✗ hydra-scala not found in PATH')
            # Try whereis on Linux
            result2 = subprocess.run(['whereis', 'hydra-scala'], capture_output=True, text=True)
            if result2.returncode == 0:
                print(f'  whereis result: {result2.stdout.strip()}')
    except FileNotFoundError:
        # On Windows, try 'where' instead of 'which'
        try:
            result = subprocess.run(['where', 'hydra-scala'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f'✓ hydra-scala found: {result.stdout.strip()}')
            else:
                print('✗ hydra-scala not found with where command')
        except Exception as e:
            print(f'✗ Could not check command availability: {e}')
    except Exception as e:
        print(f'✗ Error checking command availability: {e}')
    print()

    print('Testing classpath construction:')
    for root in search_roots:
        hydra_lib_dir = root / 'lib' / 'hydra-scala'
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

    print('SBT version check (if available):')
    try:
        # Create a minimal temporary directory for SBT to avoid the interactive prompt
        temp_dir = pathlib.Path('/tmp/sbt_test')
        temp_dir.mkdir(exist_ok=True)
        build_sbt = temp_dir / 'build.sbt'
        build_sbt.write_text('scalaVersion := "3.0.1"')

        old_cwd = os.getcwd()
        os.chdir(temp_dir)

        result = subprocess.run(['sbt', '--version'], capture_output=True, text=True, timeout=30)
        os.chdir(old_cwd)

        if result.returncode == 0:
            print('✓ SBT is available:')
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    print(f'  {line}')
        else:
            print(f'✗ SBT version check failed: {result.stderr}')
    except subprocess.TimeoutExpired:
        print('✗ SBT version check timed out')
        if 'old_cwd' in locals():
            os.chdir(old_cwd)
    except Exception as e:
        print(f'✗ Error running sbt --version: {e}')
        if 'old_cwd' in locals():
            os.chdir(old_cwd)
    finally:
        # Clean up temp directory
        if 'temp_dir' in locals() and temp_dir.exists():
            try:
                import shutil
                shutil.rmtree(temp_dir)
            except:
                pass
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
            scala_related = [d for d in lib_dirs if 'scala' in d.name.lower() or 'hydra' in d.name.lower()]
            if scala_related:
                print(f'    Scala/Hydra related lib dirs: {[d.name for d in scala_related]}')
    print()

    print('PATH environment check:')
    path_dirs = os.environ.get('PATH', '').split(os.pathsep)
    print(f'PATH has {len(path_dirs)} directories')
    relevant_paths = [p for p in path_dirs if any(keyword in p.lower() for keyword in ['conda', 'bin', 'script', 'sbt'])]
    print('Relevant PATH entries:')
    for p in relevant_paths[:10]:  # Show first 10
        print(f'  {p}')
    print()

    print()
    print('=== END DIAGNOSTIC ===')

if __name__ == '__main__':
    main()
