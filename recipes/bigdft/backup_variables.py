"""
Generate scripts that backup the environment variables which are
set by bigdftvars.sh

Usage:
    python backup_variables.py /path/to/bigdftvars.sh
"""
from sys import argv
from os.path import join, dirname

if __name__ == "__main__":
    var_file = argv[1]

    # Get a list of variables that are set, and their current values
    variables = []
    with open(var_file) as ifile:
        for line in ifile:
            exp, _ = line.split("=")
            variables.append(exp.split()[1])

    # Write a script that stores those values when sourced
    backup_file = join(dirname(var_file), "backup_conda.sh")
    with open(backup_file, "w") as ofile:
        for var in variables:
            ofile.write("export " + var + "_CONDA=$" + var + "\n")

    # Write a script that restores those values
    restore_file = join(dirname(var_file), "restore_conda.sh")
    with open(restore_file, "w") as ofile:
        for var in variables:
            ofile.write("export " + var + "=$" + var + "_CONDA\n")
            ofile.write("unset " + var + "_CONDA\n")
