# from the docs, except use CPU backend
import numpy as np
import pykeops.numpy as pknp

x = np.arange(1, 10).reshape(-1, 3).astype('float32')
y = np.arange(3, 9).reshape(-1, 3).astype('float32')

my_conv = pknp.Genred('SqNorm2(x - y)', ['x = Vi(3)', 'y = Vj(3)'])
res = my_conv(x, y, backend='CPU')
assert res.shape == (2, 1)
