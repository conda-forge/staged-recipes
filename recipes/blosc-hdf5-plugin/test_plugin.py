# coding: utf-8
from __future__ import print_function
import h5py 
import tempfile
import numpy as np

with tempfile.NamedTemporaryFile() as ntf:
    f = h5py.File(ntf.name)
    complevel = 9
    complib = 'blosc:lz4'
    shuffle = True
    data = np.random.random((1000, 1000))
    compressors = ('blosclz', 'lz4', 'lz4hc', 'snappy', 'zlib', 'zstd')
    for c in compressors:
         complib = tuple('blosc:' + c for c in compressors).index('blosc:%s' % c)
         args = {
           'compression': 32001,
           'compression_opts': (0, 0, 0, 0, complevel, shuffle, complib)
         }
         print('compression args:', args)
         f.create_dataset('test_%s' % c, data=data, chunks=True, **args)

