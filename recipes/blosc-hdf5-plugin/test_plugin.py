# coding: utf-8

import h5py 
f = h5py.File('foo.h5')
complevel=9
complib='blosc:lz4'
shuffle=True
args = {
    'compression': 32001,
    #'compression_opts': (0, 0, 0, 0, complevel, shuffle, complib)
}
f.create_dataset('test', shape=(100000, 1000), **args)
