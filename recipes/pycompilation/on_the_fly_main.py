#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""
Example where source code is present in Python module as strings.

Note how the complexity is lowered using Cython compared to
on_the_fly_low_level_main.py

Taken from https://github.com/bjodah/pycompilation/blob/master/examples/on_the_fly_main.py

LICENSE: BSD 2-Clause
"""

from __future__ import print_function, division, absolute_import

import time

import numpy as np

from pycompilation import compile_link_import_strings


sources_ = [
    ('sigmoid.c', r"""
#include <math.h>

void sigmoid(int n, const double * const restrict in,
             double * const restrict out, double lim){
    for (int i=0; i<n; ++i){
        const double x = in[i];
        out[i] = x*pow(pow(x/lim, 8)+1, -1./8.);
    }
}
"""),
    ('_sigmoid.pyx', r"""
import numpy as np
cimport numpy as cnp

cdef extern void c_sigmoid "sigmoid" (int, const double * const,
                                      double * const, double)

def sigmoid(double [:] inp, double lim=350.0):
    cdef cnp.ndarray[cnp.float64_t, ndim=1] out = np.empty(
        inp.size, dtype=np.float64)
    c_sigmoid(inp.size, &inp[0], &out[0], lim)
    return out
""")
]


def npy(data, lim=350.0):
    return data/((data/lim)**8+1)**(1/8.)


def timeit(cb, data):
    t = time.time()
    best = 9999999999999999
    for i in range(5):
        t = time.time()
        res = cb(data)
        best = min(time.time()-t, best)
    return best, res


def main():
    mod = compile_link_import_strings(
        sources_, options=['fast', 'warn', 'pic'], std='c99',
        logger=True, include_dirs=[np.get_include()])
    data = np.random.random(1024*1024*8)  # 64 MB of RAM needed..
    t_mod, res_mod = timeit(mod.sigmoid, data)
    t_npy, res_npy = timeit(npy, data)
    assert np.allclose(res_mod, res_npy)
    print(t_mod, t_npy)


if __name__ == '__main__':
    main()
