#!/usr/bin/env python

# Install graphviz Python package
import pip
pip.main(['install', 'graphviz'])

# Dask test
import dask.array as da
x = da.ones(4, chunks=(2,))
for fmt in ['pdf', 'png', 'dot', 'svg']:
    (x + 1).sum().visualize(filename='graph.%s' % fmt)
