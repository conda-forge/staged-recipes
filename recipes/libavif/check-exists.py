import argparse
import os
import platform

_lib_extensions = {
    'Linux': 'so',
    'Darwin': 'dylib',
    'Windows': 'lib',
}


def _print_exists(filename):
    """Prints the names of missing files.

    Return False if anything is missing else return True.
    """
    if os.path.exists(filename):
        return True
    else:
        print(f"ERROR: {filename} is MISSING!")
        return False


def libraries_exist(major, minor, patch):
    """Check that the AVIF library is installed for given version.

    Return False if anything is missing else return True.

    NOTE: libavif release number does not match the shared library version.
    """
    exists = True

    filename = os.path.join(os.environ['PREFIX'], 'lib', 'libavif')

    extension = _lib_extensions[platform.system()]

    if platform.system() == 'Darwin':
        for library in [f'{filename}.{major}.{minor}.{patch}.{extension}']:
            exists = exists and _print_exists(library)

    else:  # Windows Linux
        for library in [f'{filename}.{extension}.{major}.{minor}.{patch}']:
            exists = exists and _print_exists(library)

    return exists


def cmake_config_exist():
    """Checks that CMAKE config and pkgconfig files were installed.

    Return False if anything is missing else return True.
    """
    exists = True

    exists = exists and _print_exists(
        os.path.join(os.environ['PREFIX'], 'lib', 'pkgconfig', 'libavif.pc'))

    for middle in [
            '',
            '-release',
            '-version',
    ]:
        exists = exists and _print_exists(
            os.path.join(os.environ['PREFIX'], 'lib', 'cmake', 'libavif',
                         f'libavif-config{middle}.cmake'))

    return exists


def headers_exist():
    return _print_exists(
        os.path.join(os.environ['PREFIX'], 'include', 'avif', 'avif.h'))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Check whether libavif has all components installed.')
    parser.add_argument('MAJOR', type=int, help='Major library version')
    parser.add_argument('MINOR', type=int, help='Minor library version')
    parser.add_argument('PATCH', type=int, help='Patch library version')
    args = parser.parse_args()
    assert (libraries_exist(args.MAJOR, args.MINOR, args.PATCH)
            and headers_exist()
            and cmake_config_exist()), "There are libavif files missing!"
