#!/usr/bin/env python

import os

# This is failing for now on Windows. We need to submit
# a patch to the graphviz package to fix it
if not os.name == 'nt':
    # Install graphviz Python package
    import pip
    pip.main(['install', 'graphviz'])

    # Dask test
    import dask.array as da
    x = da.ones(4, chunks=(2,))
    for fmt in ['pdf', 'png', 'dot', 'svg']:
        (x + 1).sum().visualize(filename='graph.%s' % fmt)
