#!/opt/anaconda1anaconda2anaconda3/bin/python

import sys
import os
from subprocess import Popen, PIPE, CalledProcessError

ENV_PATH = os.path.dirname(os.path.realpath(__file__))[:-3]

cmd = ['{}/bin/java'.format(ENV_PATH), '-jar', '{}/PaDEL-Descriptor.jar'.format(ENV_PATH)] + sys.argv[1:]

with Popen(cmd, stdout=PIPE, bufsize=1, universal_newlines=True) as p:
    for line in p.stdout:
        print(line, end='')

if p.returncode != 0:
    raise CalledProcessError(p.returncode, p.args)