"""
Created on Sat Jan 27 17:18:46 2018

@author: Mostafa
"""
#%% paths & links
from IPython import get_ipython   # to reset the variable explorer each time
get_ipython().magic('reset -f')
import os
os.chdir("F:/02Private/02Research/thesis/My Thesis/Data_and_Models/Model/Code/06Fully_distributed/")
import sys
sys.path.append("F:/02Private/02Research/thesis/My Thesis/Data_and_Models/Model/Code/python_functions/")
# precipitation data
datapath="F:/02Private/02Research/thesis/My Thesis/Data_and_Models/Data/05new_model/outputs/4km/"
# DEM
dempath="F:/02Private/02Research/thesis/My Thesis/Data_and_Models/Data/05new_model/new/dem_4km.tif"
# calibration data
calibopath="F:/02Private/02Research/thesis/My Thesis/Data_and_Models/Data/03semi_distributed(2)/matlab/calibration/"
#%%library
import numpy as np
#import matplotlib.pyplot as plt
import scipy.io as spio
import gdal

from Oasis.Optimization import Optimization
# from Oasis.Optimizer import Optimizer
from Oasis.pyALHSO import ALHSO
# from Oasis import Constraint

#import pandas as pd
import datetime as dt


# functions
from alldataold import alldata
from wrapper import calib_tot_distributed_new_model_structure2
from HBV96d_edited import _get_mask
from save_dict import load_obj
#from par3d import par3d_lumpedK1_newmodel2
#import HBV_explicit
#import HBV96d_edited_trials as HBV96d
#from muskingum import muskingum_routing
#from flow_direction import flow_direction
#%% lake subcatchment (load data)
totaldata,_, p2,curve=alldata(typee='hourly')
data=spio.loadmat(calibopath+'vlake.mat')
totaldata['plake']=data['vlake'][:,0]
del totaldata['p'], data

s=dt.datetime(2012,6,14,19,0,0)
e=dt.datetime(2013,12,23,0,0,0)
e2=dt.datetime(2014,11,17,0,0,0)

calib=totaldata.loc[s:e]
calibration_array=calib.values
sp_prec_c=np.load(datapath+'sp_prec_c.npy')
#sp_prec_c=sp_prec_c.astype(np.float32)
sp_et_c=np.load(datapath+'sp_et_c.npy')
#sp_et_c=sp_et_c.astype(np.float32)
sp_temp_c=np.load(datapath+'sp_temp_c.npy')
#sp_temp_c=sp_temp_c.astype(np.float32)


flow_acc_table=load_obj(datapath+"flow_acc_table")
flow_acc=np.load(datapath+'flow_acc.npy')
#flow_acc=flow_acc.astype(np.float16)
lakecell=[2,1] # 4km

#no_cells=np.size(flow_direct[:,:,0])-np.count_nonzero(np.isnan(flow_direct[:,:,0]))

DEM = gdal.Open(dempath)
shape_base_dem = DEM.ReadAsArray().shape
elev, no_val=_get_mask(DEM)
elev[elev==no_val]=np.nan
no_cells=np.size(elev[:,:])-np.count_nonzero(np.isnan(elev[:,:]))
#elev=np.array(elev,dtype='float32')
#no_val=np.float32(no_val)

#%% parameters
# 168 parameters

jiboa_initial=np.loadtxt('01txt\\Initia-jiboa.txt',usecols=0).tolist()
lake_initial=np.loadtxt('01txt\\Initia-lake.txt',usecols=0).tolist()
LB=np.loadtxt('01txt\\constrained_muskingum\\LB-4km.txt',usecols=0).tolist()#[:9]
UB=np.loadtxt('01txt\\constrained_muskingum\\UB-4km.txt',usecols=0).tolist()#[:9]
#
klb=0.5
kub=1.5
#%% harmony_search
harmony_search=1


par=np.random.uniform(LB, UB)
print('Calibration starts')

# 1- Objective Function
def opt_fun(par):
    try:
        _,_, RMSEE ,_, _, _=calib_tot_distributed_new_model_structure2(calibration_array,
                         p2,curve,lakecell,DEM,flow_acc_table,flow_acc,sp_prec_c,sp_et_c,
                         sp_temp_c, par,kub,klb,jiboa_initial=jiboa_initial,
                         lake_initial=lake_initial,ll_temp=None, q_0=None)
        print("RMSE = " + str(RMSEE))
        # print(par)
        fail = 0
    except:
        RMSEE = np.nan
        fail = 1
    return RMSEE, [], fail

# 2- first create the variable, parameter objects
# and hand it to the optimization object


#Contraint1 = Constraint("constraint1", type='i', *args, **kwargs)

# 3-Optimization object
opt_prob = Optimization('HBV Calibration', opt_fun)

# 4- add variable to the Optimization object
# if you want to give the algorithm any initial values give it to the addVar method
# with a keyword argument value
for i in range(len(LB)):# [:10]
    opt_prob.addVar('x{0}'.format(i), value=LB[i], type='c', lower=LB[i], upper=UB[i])

# 2- first create the constraint,
# A- Constraint object
#c1=(2*x1*x2)-1
#c2=1-(2*x1*(1-x2))
# opt_prob.addCon()
# write the optimization problem with the __str__ method
print(opt_prob)

# 5- create the Optimizer and the ALHSO object (Optimizer is a super class and
# ALHSO is a sub class)
# any options you want to pass to the optimizer object you have to put it in
# a dict and call it options and use the options name as a key in the dict
options = dict(etol=0.0001,atol=0.0001,rtol=0.0001, stopiters=10, hmcr=0.5,
               par=0.5, hms = 3, dbw = 3000,
               fileout = 1, filename ='parameters.txt',
            	seed = 0.5, xinit = 1, scaling = 0,
				prtinniter = 1, prtoutiter = 1, stopcriteria = 1,
				maxoutiter = 2)

opt_engine = ALHSO(pll_type = 'POA',options = options)

# 6- call the optimizer to solve the optimization problem
res = opt_engine(opt_prob, store_sol=True, display_opts=True, store_hst=True,
                 hot_start=False,filename="mostafa.txt")