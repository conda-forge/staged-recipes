#!/usr/bin/env python

import os
import subprocess
import sys


# The code doesn't have a test suite, but it
# does have some examples included with some
# documentation. Here we just recurse through
# the examples and search for Python files.
# If we find some, we try to run them.

src_dir = os.path.abspath(os.environ["SRC_DIR"])
example_dir = os.path.join(src_dir, "examples")

scripts = []
for cwd, dirs, files in os.walk(example_dir):
    for each_file in files:
        if each_file.endswith(".py"):
            scripts.append(os.path.join(cwd, each_file))

for each_script in scripts:
    os.chdir(os.path.dirname(each_script))
    with open(each_script.replace(".py", ".out"), "w") as each_out:
        print("Running \"%s\"..." % each_script)
        print("Output redirected to \"%s\"." % each_out.name)
        subprocess.check_call(
            [
                sys.executable,
                os.path.basename(each_script)
            ],
            stdout=each_out
        )
        print("Finished running \"%s\"." % each_script)
