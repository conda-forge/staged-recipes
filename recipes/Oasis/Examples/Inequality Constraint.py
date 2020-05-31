# -*- coding: utf-8 -*-
"""
Created on Sun Feb  2 18:39:36 2020

@author: mofarrag
"""
from IPython import get_ipython
get_ipython().magic("reset -f")
import os
os.chdir("F:/01Algorithms/Oasis/Examples")
from numpy import power
from Oasis.optimization import Optimization
from Oasis.pyALHSO import ALHSO


def objfunc(x):
        f = power(x[0]**2 * x[1]**2, 1. / 3.) - x[0] + x[1]**2
		# Uniquality Constraint: 9 - x**2 - y**2 >= 0
        g = [x[0]**2 + x[1]**2 - 9]
        print('Uniquality Constraint = ' + str(g))
        print('Obj Fn value = ' + str(f))
        fail = 0
        return f, g, fail

opt_prob = Optimization('A third root function', objfunc)
opt_prob.addVar('x1', 'c', lower=-3, upper=3, value=0.0)
opt_prob.addVar('x2', 'c', lower=-3, upper=3, value=0.0)
opt_prob.addObj('f')
opt_prob.addCon('g1', 'i')


# options = dict(etol=0.0001,atol=0.0001,rtol=0.0001, stopiters=10, hmcr=0.5,
#                par=0.9, hms = 10, dbw = 3000,
#                fileout = 1, filename ='parameters.txt',
#             	seed = 0.5, xinit = 1, scaling = 0,
# 				prtinniter = 1, prtoutiter = 1, stopcriteria = 1,
# 				maxoutiter = 2)

opt_engine = ALHSO(pll_type = 'POA') #,options = options

res = opt_engine(opt_prob, store_sol=True, display_opts=True, store_hst=True,
                 hot_start=False,filename="mostafa.txt")