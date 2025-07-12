
import unittest
import numpy as np
import sys
# appending a path
sys.path.append('../')

from pychop.chop import chop
from scipy.io import loadmat
import pychop

pychop.backend('numpy', 1) # print information, NumPy is the default option.


X_np = loadmat("verified_data.mat")
X_np = X_np['array'][0]

import torch
import jax
from jax import config
pychop.backend('jax')
config.update("jax_enable_x64", True)

X_th = torch.Tensor(X_np) # torch array
X_jx = jax.numpy.float64(X_np)


class TestClassix(unittest.TestCase):
    
    def test_backend(self):
        check_point = 1
        try:
            pychop.backend('jax')
            pychop.backend('torch')
            pychop.backend('numpy', 1)
        except:
            check_point = 0

        assert(check_point == 1)
        


    def test_q52(self):
        ch = chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    def test_43(self):
        ch = chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half(self):

        ch = chop('h', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = chop('h', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")



    def test_bfloat16(self):
        ch = chop('b', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('b', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = chop('bfloat16', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('b', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    # pytorch
    def test_q52_th(self): 
        pychop.backend('torch')
        ch = chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    def test_43_th(self):
        pychop.backend('torch')
        ch = chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half_th(self):
        pychop.backend('torch')
        ch = chop('h', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = chop('h', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_bfloat16_th(self):
        pychop.backend('torch')
        ch = chop('b', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")


        ch = chop('b', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = chop('b', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('b', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    # jax
    def test_q52_jx(self): 
        pychop.backend('jax')
        ch = chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_bfloat16_jx(self):
        ch = chop('b', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('b', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = chop('b', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('b', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('b', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('b', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half_jx(self):
        ch = chop('h', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = chop('h', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('h', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('h', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('h', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_43_jx(self):
        ch = chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


if __name__ == '__main__':
    unittest.main()