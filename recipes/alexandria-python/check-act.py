"""Test of the conda package alexandria-python: the package act runs the
alexandria program of its environment, see recipe.yaml."""
import os
import sys

import act


def inside(path: str) -> bool:
    """Whether a file is in the environment of this Python."""
    prefix = os.path.realpath(sys.prefix)
    return os.path.commonpath([prefix, os.path.realpath(path)]) == prefix


assert inside(act.__file__), act.__file__
# Pure Python for now: no classes
assert not act.classes_available()
# The program of the environment, through the path in act/_installed.py
program = act.runner.installed_program()
assert program and inside(program), program
words = act.config.executable_words()
assert words[0] == program, words
# Runs 'alexandria help -export json'
assert "train_ff" in act.commands.available()
print("act", act.__file__, "runs", program)
