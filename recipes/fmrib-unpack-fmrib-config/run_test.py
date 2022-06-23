#!/usr/bin/env python

import os.path as op
import            os
import            glob
import            site

for sitedir in site.getsitepackages():
    fpdir = op.join(sitedir, 'funpack')
    if not op.exists(fpdir):
        continue
    for dirpath, _, filenames in os.walk(fpdir):
        for filename in filenames:
            print(op.join(dirpath, filename))
    break

else:
    raise AssertionError('Cannot find FUNPACK fmrib configuration files')
