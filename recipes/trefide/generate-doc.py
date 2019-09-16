#!//usr/bin/env python

# execute this script in doc folder

import os

module_list = ["trefide", "trefide.decimation", "trefide.filter", "trefide.plot", "trefide.pmd", "trefide.preprocess",
               "trefide.reformat", "trefide.temporal", "trefide.utils", "trefide.video"]

for item in module_list:
    os.system("pydoc3 -w " + item)

