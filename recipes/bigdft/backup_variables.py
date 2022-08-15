"""
Generate scripts that backup the environment variables which are
set by bigdftvars.sh

Usage:
    python backup_variables.py /path/to/bigdftvars.sh
"""
from sys import argv
from os.path import join, dirname
from os import environ

if __name__ == "__main__":
    var_file = argv[1]

    # Get a list of variables that are set, and their current values
    variables = {}
    with open(var_file) as ifile:
        for line in ifile:
            exp, _ = line.split("=")
            var = exp.split()[1]
            variables[var] = environ.get(var)

    # Write a script that stores those values when sourced
    backup_file = join(dirname(var_file), "backup_conda.sh")
    with open(backup_file, "w") as ofile:
        for var, val in variables.items():
            ofile.write("export " + var + "_CONDA=")
            if val is None:
                ofile.write('""')
            else:
                ofile.write(val)
            ofile.write("\n")

    # Write a script that restores those values
    restore_file = join(dirname(var_file), "restore_conda.sh")
    with open(restore_file, "w") as ofile:
        for var, val in variables.items():
            ofile.write("export " + var + "=$" + var + "_CONDA\n")
    print(backup_file)
    print(restore_file)
    pass
