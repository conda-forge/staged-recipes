from optparse import OptionParser
import subprocess as sp
import re
from itertools import zip_longest

INVALID_NAME_MAP = {
    'r-edger': 'bioconductor-edger',
}


def write_recipe(package, recipe_dir='.', no_windows=True, config=None, force=False, bioc_version=None,
                 pkg_version=None, versioned=False, ):
        sp.call(['conda skeleton cran '+ package + ' --output-dir ' + recipe_dir], shell=True)
        clean_skeleton_files(recipe_dir + '/r-' + package, no_windows)


def clean_skeleton_files(package, no_windows):
    # Cleans the yaml and build files to make them conda-forge compatible.

    clean_yaml_file(package, no_windows)
    clean_build_file(package, no_windows)
    clean_bld_file(package, no_windows)


def clean_yaml_file(package, no_windows):
    lines = []
    path = package + '/meta.yaml'
    with open(path, 'r') as yaml:
        lines = list(yaml.readlines())
        lines = remove_comments(lines)
        lines = remove_empty_lines(lines)
        lines = remove_file_licences(lines)
        lines = add_gpl2(lines)
        lines = add_gpl3(lines)
        if no_windows:
            lines = skip_windows32(lines)
        add_maintainers(lines)

    with open(path, 'w') as yaml:
        out = "".join(lines)
        out = out.replace('{indent}', '\n    - ')
        for wrong, correct in INVALID_NAME_MAP.items():
            out = out.replace(wrong, correct)
        yaml.write(out)


def clean_build_file(package, no_windows):
    # Clean build.sh file

    path = package + '/build.sh'
    with open(path, 'r') as build:
        lines = list(build.readlines())
        lines = remove_mv(lines)
        lines = remove_grep(lines)
        lines = remove_comments(lines)
        lines = remove_empty_lines(lines)

    with open(path, 'w') as build:
        build.write("".join(lines))


def clean_bld_file(package, no_windows):
    # Clean bld.bat file

    path = package + '/bld.bat'
    with open(path, 'r') as bld:
        lines = list(bld.readlines())
        lines = remove_at(lines)
        lines = remove_empty_lines(lines)

    with open(path, 'w') as bld:
        bld.write("".join(lines))


def remove_comments(lines):
    # Removes the lines consisting of only comments
    return [line for line in lines if (not re.search(r'^\s*#.*$', line))]


def remove_empty_lines(lines):
    # Removes consecutive empty lines from a file

    cleaned_lines = []

    for line, next_line in zip_longest(lines, lines[1:]):
        if (line.isspace() and next_line is None) or (line.isspace() and next_line.isspace()):
            pass
        else:
            cleaned_lines.append(line)

    if cleaned_lines[0].isspace():
        cleaned_lines = cleaned_lines[1:]
    return cleaned_lines


def remove_at(lines):
    # Removes the lines that start with @

    return [line for line in lines if not re.search(r'^@.*$', line)]


def remove_mv(lines):
    # Remove lines with mv commands

    return [line for line in lines if not re.search(r'^mv\s.*$', line)]


def add_gpl2(lines):
    return [re.sub(r"  license_family: GPL2", "  license_family: GPL2\n  license_file: '{{ environ[\"PREFIX\"] }}"
                                              "\/lib\/R\/share\/licenses\/GPL-2'  # [unix]\n  "
                                              "license_file: '{{ environ[\"PREFIX\"] }}"
                                              "\\\R\\\share\\\licenses\\\GPL-2'  # [win]", line) for line in lines]


def add_gpl3(lines):
    return [re.sub(r"  license_family: GPL3", "  license_family: GPL3\n  license_file: '{{ environ[\"PREFIX\"] }}"
                                              "\/lib\/R\/share\/licenses\/GPL-3'  # [unix]\n  "
                                              "license_file: '{{ environ[\"PREFIX\"] }}"
                                              "\\\R\\\share\\\licenses\\\GPL-3'  # [win]", line) for line in lines]


def remove_grep(lines):
    # Remove lines with grep commands
    return [line for line in lines if not re.search(r'^grep\s.*$', line)]


def skip_windows32(lines):
    # Inserts the skip: true # [win32] after number: 0, to skip windows builds
    return [re.sub(r'number: 0', 'number: 0\n  skip: true  # [win32]', line) for line in lines]


def remove_file_licences(lines):
    return [re.sub(r' [+|] file LICEN[SC]E', '', line) for line in lines]


def add_maintainers(lines):
    with open("maintainers.yaml", 'r') as yaml:
        extra_lines = list(yaml.readlines())
        lines.extend(extra_lines)


def main():
    """ Adding support for arguments here """
    usage = "usage: %prog [options] arg"
    parser = OptionParser(usage)
    parser.add_option('--cran', nargs=2, dest="cran",
                      help='runs the skeleton on a cran package with parameters: <package> <recipe_dir>')
    parser.add_option('--no_win', default=False, dest="no_windows", action="store_true",
                      help='runs the skeleton and removes windows specific information')

    (options, args) = parser.parse_args()

    if options.cran is not None:
        packageName = options.cran[0]
        recipe_dir = options.cran[1]
        no_windows = options.no_windows
        write_recipe(packageName, recipe_dir, no_windows=no_windows)


if __name__ == '__main__':
    main()
