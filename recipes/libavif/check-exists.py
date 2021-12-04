import argparse
import os
import platform


def _print_exists(filename):
    """Prints the names of missing files.

    Return False if anything is missing else return True.
    """
    if os.path.exists(filename):
        print(f"FOUND: {filename}")
        return True
    else:
        print(f"ERROR: {filename} is MISSING!")
        return False


def libraries_exist(prefix, major, minor, patch):
    """Check that the AVIF library is installed for given version.

    Return False if anything is missing else return True.

    NOTE: libavif release number does not match the shared library version.
    """
    exists = True

    filename = os.path.join(prefix, 'lib', 'libavif')

    if platform.system() == 'Darwin':
        for library in [
                f'{filename}.dylib',
                f'{filename}.{major}.dylib',
                f'{filename}.{major}.{minor}.{patch}.dylib',
        ]:
            exists = exists and _print_exists(library)
    elif platform.system() == 'Windows':
        exists = exists and _print_exists(
            os.path.join(prefix, 'lib', 'avif.lib'))
        exists = exists and _print_exists(
            os.path.join(prefix, 'bin', 'avif.dll'))
    else:  # Linux
        for library in [
                f'{filename}.so',
                f'{filename}.so.{major}',
                f'{filename}.so.{major}.{minor}.{patch}',
        ]:
            exists = exists and _print_exists(library)

    return exists


def cmake_config_exist():
    """Checks that CMAKE config and pkgconfig files were installed.

    Return False if anything is missing else return True.
    """
    exists = True

    exists = exists and _print_exists(
        os.path.join(prefix, 'lib', 'pkgconfig', 'libavif.pc'))

    for middle in [
            '',
            '-release',
            '-version',
    ]:
        exists = exists and _print_exists(
            os.path.join(prefix, 'lib', 'cmake', 'libavif',
                         f'libavif-config{middle}.cmake'))

    return exists


def headers_exist(prefix):
    return _print_exists(os.path.join(prefix, 'include', 'avif', 'avif.h'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Check whether libavif has all components installed.')
    parser.add_argument('MAJOR', type=int, help='Major library version')
    parser.add_argument('MINOR', type=int, help='Minor library version')
    parser.add_argument('PATCH', type=int, help='Patch library version')
    args = parser.parse_args()
    if platform.system() == 'Windows':
        prefix = os.environ['LIBRARY_PREFIX']
    else:
        prefix = os.environ['PREFIX']
    assert (libraries_exist(prefix, args.MAJOR, args.MINOR, args.PATCH)
            and headers_exist(prefix)
            and cmake_config_exist(prefix)), "There are libavif files missing!"
