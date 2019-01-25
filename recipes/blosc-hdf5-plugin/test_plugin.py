# coding: utf-8

import h5py 
import tempfile

with tempfile.NamedTemporaryFile() as ntf:
    f = h5py.File(ntf.name)
    complevel = 9
    complib = 'blosc:lz4'
    shuffle = True
    compressors = ('blosclz', 'lz4', 'lz4hc', 'snappy', 'zlib', 'zstd')
    complib = tuple('blosc:' + c for c in compressors).index(complib)
    args = {
        'compression': 32001,
        'compression_opts': (0, 0, 0, 0, complevel, shuffle, complib)
    }
    f.create_dataset('test', shape=(100, 1000), **args)
