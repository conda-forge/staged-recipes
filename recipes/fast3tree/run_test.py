#!/usr/bin/env python
import numpy as np
from fast3tree import fast3tree

data = np.random.rand(10000, 3)
with fast3tree(data) as tree:
    idx = tree.query_radius([0.5, 0.5, 0.5], 0.2)
    print("idx:", idx, flush=True)
