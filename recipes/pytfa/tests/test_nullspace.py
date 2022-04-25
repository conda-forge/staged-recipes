import pytest

from skimpy.nullspace import left_integer_nullspace

import numpy as np
from scipy.sparse import random
from scipy import stats

class ThisCustomRandomState(np.random.RandomState):

    def randint(self, k):
        i = np.random.randint(k)
        return i

    def choice(self, mn, size, replace):
        return np.random.choice(mn, size=size, replace=replace)


def test_left_nullspace():

    rs = ThisCustomRandomState()
    rvs = stats.poisson(2, loc=10).rvs
    S = random(5,6, density=0.1, random_state=rs, data_rvs=rvs, dtype=np.int)

    # print(S.todense())

    ns = left_integer_nullspace(S.todense())

    # print(ns)
    null = ns @ S.todense()

    # print(null)
    # assert(np.any(null) == False)
    assert(null.max() < 1e-12)