
import unittest
import numpy as np
import sys
import pychop

from pychop.chop import Chop
from scipy.io import loadmat
from pychop import LightChop
from pychop.tch.lightchop import LightChopSTE

import torch


pychop.backend('numpy') # print information, NumPy is the default option.


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


if __name__ == '__main__':
    unittest.main()
