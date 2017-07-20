import numpy as np
import ot

n = 5
a, b = np.random.dirichlet([1] * n, size=2)
M = ot.dist(np.random.randn(n, 5), metric='canberra')

W = ot.emd2(a, b, M)
W_reg = ot.sinkhorn2(a, b, M, .1)

T = ot.emd(a, b, M)
T_reg = ot.sinkhorn(a, b, M, .1)
