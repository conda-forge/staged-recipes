
import unittest
import numpy as np
import sys

import pychop

from pychop.chop import Chop
from scipy.io import loadmat
from pychop import LightChop
from pychop.tch.lightchop import LightChopSTE

import torch
import jax
from jax import config

config.update("jax_enable_x64", True)

pychop.backend('numpy') # print information, NumPy is the default option.


X_np = loadmat("tests/verified_data.mat")
X_np = X_np['array'][0]

X_th = torch.from_numpy(X_np) # torch array
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
        pychop.backend('numpy', 1)
        ch = Chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = Chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    def test_43(self):
        pychop.backend('numpy', 1)
        ch = Chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = Chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half(self):
        pychop.backend('numpy', 1)
        ch = Chop('h', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = Chop('h', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")



    def test_bfloat16(self):
        pychop.backend('numpy', 1)
        ch = Chop('b', rmode=1, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('b', rmode=3, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=0)
        emulated= ch(X_np)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_np_scaling = X_np / scaling

        ch = Chop('bfloat16', rmode=1, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('b', rmode=3, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    # pytorch
    def test_q52_th(self): 
        pychop.backend('torch')
        ch = Chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = Chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    def test_43_th(self):
        pychop.backend('torch')
        ch = Chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = Chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half_th(self):
        pychop.backend('torch')
        ch = Chop('h', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = Chop('h', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_bfloat16_th(self):
        pychop.backend('torch')
        ch = Chop('b', rmode=1, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")


        ch = Chop('b', rmode=3, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=0)
        emulated= ch(X_th)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_th_scaling = X_th / scaling

        ch = Chop('b', rmode=1, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('b', rmode=3, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    # jax
    def test_q52_jx(self): 
        pychop.backend('jax')
        ch = Chop('q52', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = Chop('q52', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q52', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q52', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q52', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q52/q52_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_bfloat16_jx(self):
        pychop.backend('jax')
        ch = Chop('b', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('b', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = Chop('b', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('b', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('b', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('b', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/bfloat16/bfloat16_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_half_jx(self):
        pychop.backend('jax')
        ch = Chop('h', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = Chop('h', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('h', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('h', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('h', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")


    def test_43_jx(self):
        pychop.backend('jax')
        ch = Chop('q43', rmode=1, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=0)
        emulated= ch(X_jx)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_0.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

        scaling = 1000
        X_jx_scaling = X_jx / scaling

        ch = Chop('q43', rmode=1, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")

        ch = Chop('q43', rmode=2, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")

        ch = Chop('q43', rmode=3, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = Chop('q43', rmode=4, subnormal=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/q43/q43_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 4")

    def test_custom_precs(self):
        from pychop import Customs
        pychop.backend('numpy', 1) 

        ct1 = Customs(emax=15, t=11) 
        pyq_f = Chop(customs=ct1, rmode=3) 
        emulated1 = pyq_f(X_np)
        
        ct2 = Customs(exp_bits=5, sig_bits=10) 
        pyq_f = Chop(customs=ct2, rmode=3)
        emulated2 = pyq_f(X_np)
        assert np.array_equal(emulated1, emulated2)

    def test_lightchop1(self):
        # Test values
        values = torch.tensor([1.7641, 0.3097, -0.2021, 2.4700, 0.3300])
        # Test all rounding modes
        rounding_modes = ["nearest", "up", "down", "towards_zero", 
                            "stochastic_equal", "stochastic_proportional"]

        # Compare with PyTorch's native FP16
        fp16_native = values.to(dtype=torch.float16).to(dtype=torch.float32)

        print("Input values:      ", values)
        print("PyTorch FP16:      ", fp16_native)
        print()

        print()
        rounding_modes_num = [1, 2, 3, 4, "stochastic_equal", "stochastic_proportional"]

        print("Correct ones:")
        for mode in rounding_modes_num[:4]:
            pyq_f = Chop('h', rmode=mode)
            groud_truth = pyq_f(values)

            # Half precision simulator (5 exponent bits, 10 significand bits)
            fp16_sim = LightChop(5, 10, mode)
            emulated = fp16_sim(values)
            assert np.array_equal(emulated, groud_truth), print("error rmode 3")
            
            print(f"{rounding_modes[mode-1]:12}, ", "Truth:", f"   {emulated}")
            print(f"{rounding_modes[mode-1]:12}, ", "Emulated:", f"{groud_truth}")


    def test_lightchop2(self):
        pychop.backend('torch')
        scaling = 1000
        X_th_scaling = X_th / scaling
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=1)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=2)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=3)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = LightChop(exp_bits=5, sig_bits=10, rmode=4)
        emulated= ch(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")


    def test_lightchop22(self):
        pychop.backend('torch')
        scaling = 1000
        X_th_scaling = X_th / scaling
        
        ch = LightChopSTE(exp_bits=5, sig_bits=10, rmode=1)
        emulated= ch.quantize(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")
        
        ch = LightChopSTE(exp_bits=5, sig_bits=10, rmode=2)
        emulated= ch.quantize(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")
        
        ch = LightChopSTE(exp_bits=5, sig_bits=10, rmode=3)
        emulated= ch.quantize(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = LightChopSTE(exp_bits=5, sig_bits=10, rmode=4)
        emulated= ch.quantize(X_th_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

    def test_lightchop3(self):
        pychop.backend('jax')
        scaling = 1000
        X_jx_scaling = X_jx / scaling
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=1)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=2)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=3)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = LightChop(exp_bits=5, sig_bits=10, rmode=4)
        emulated= ch(X_jx_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")



    def test_lightchop3(self):
        pychop.backend('numpy')
        scaling = 1000
        X_np_scaling = X_np / scaling
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=1)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_1_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 1")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=2)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_2_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 2")
        
        ch = LightChop(exp_bits=5, sig_bits=10, rmode=3)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_3_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")

        ch = LightChop(exp_bits=5, sig_bits=10, rmode=4)
        emulated= ch(X_np_scaling)
        groud_truth = loadmat("tests/half/half_rmode_4_subnormal_1.mat")
        groud_truth = groud_truth["emu_vals"].flatten()
        assert np.array_equal(emulated, groud_truth), print("error rmode 3")


if __name__ == '__main__':
    unittest.main()
