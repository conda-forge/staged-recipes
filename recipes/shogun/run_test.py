import numpy as np
import modshogun as sg

X = np.random.randn(100, 3)
Y = np.random.randn(100, 3) + .5

mmd = sg.QuadraticTimeMMD()
mmd.set_p(sg.RealFeatures(X.T))
mmd.set_q(sg.RealFeatures(Y.T))
mmd.set_kernel(sg.GaussianKernel(32, 1))
mmd.set_num_null_samples(200)
samps = mmd.sample_null()
stat = mmd.compute_statistic()
