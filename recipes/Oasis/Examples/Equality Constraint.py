# -*- coding: utf-8 -*-
"""
Created on Sun Feb  2 19:22:18 2020

@author: mofarrag
"""


from IPython import get_ipython
get_ipython().magic("reset -f")
import os
os.chdir("F:/01Algorithms/Oasis/Examples")
from Oasis.optimization import Optimization
from Oasis.pyALHSO import ALHSO



def objfunc(x):
        f = x[0]**2 + x[1]**2 + x[2]**4
        g = [x[0] + x[1] + x[2] - 4]
        print('Equality Constraint = ' + str(g))
        print('Obj Fn value = ' + str(f))
        fail = 0
        return f, g, fail

opt_prob = Optimization('Testing solutions', objfunc)
opt_prob.addVar('x1', 'c', lower=-4, upper=4, value=0.0)
opt_prob.addVar('x2', 'c', lower=-4, upper=4, value=0.0)
opt_prob.addVar('x3', 'c', lower=-4, upper=4, value=0.0)
opt_prob.addObj('f')
opt_prob.addCon('g1', 'e')


options = dict(stopiters=5,
               fileout = 1, filename ='EqualityConstraint.txt',
				prtinniter = 1, prtoutiter = 1)

opt_engine = ALHSO(pll_type = 'POA',options = options)

res = opt_engine(opt_prob, store_sol=True, display_opts=True, store_hst=False,
                 hot_start=False,filename="mostafa.txt")