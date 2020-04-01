import sys, platform, os
import numpy as np

#Assume installed from github using "git clone --recursive https://github.com/cmbant/CAMB.git"
#This file is then in the docs folders
isitgr_path = os.path.realpath(os.path.join(os.getcwd(),'..'))
sys.path.insert(0,isitgr_path)
import isitgr
from isitgr import model, initialpower
print('Using CAMB-ISiTGR %s installed at %s'%(isitgr.__version__,os.path.dirname(isitgr.__file__)))

# Defining array for different MG parameter values.
E11 = [1, -1, 0.5, 0]
E22 = [1, -1, 0.5, 1]

# Set up different set of parameters for CAMB (including MG)
pars_GR = isitgr.CAMBparams()
pars_MG1 = isitgr.CAMBparams()

# This function sets up CosmoMC-like settings, with one massive neutrino and helium set using BBN consistency

# For GR
pars_GR.set_cosmology(H0=70, ombh2=0.0226, omch2=0.112, mnu=0, omk=0, tau=0.09)
pars_GR.InitPower.set_params(As=2.1e-9, ns=0.96, r=0)
pars_GR.set_for_lmax(2500, lens_potential_accuracy=0);

# For MG model 1. Here we set parameterization="mueta". 
# No scale dependence is considered in any MG model since we do not call c1, c2 or Lambda parameters...
pars_MG1.set_cosmology(H0=70, ombh2=0.0226, omch2=0.112, mnu=0, omk=0, tau=0.09,
                  parameterization="mueta", E11=E11[0], E22=E22[0])
pars_MG1.InitPower.set_params(As=2.1e-9, ns=0.96, r=0)
pars_MG1.set_for_lmax(2500, lens_potential_accuracy=0);

# Calculate results for different models.
results_GR = isitgr.get_results(pars_GR)
results_MG1 = isitgr.get_results(pars_MG1)

# (1) camb.get_results() compute results for specified parameters and return CAMBdata.
# (2) camb.results.CAMBdata is an object for storing calculational data, parameters and transfer functions.

# Get dictionary of CAMB power spectra for different models, including GR and MG models.
powers_GR =results_GR.get_cmb_power_spectra(pars_GR, CMB_unit='muK')
powers_MG1 =results_MG1.get_cmb_power_spectra(pars_MG1, CMB_unit='muK')

# Here we obtain the total lensed CMB power spectra
totCL_GR=powers_GR['total']
totCL_MG1=powers_MG1['total']

# Here we obtain the cl's for lensing potential.

# For GR
pars_GR.set_dark_energy(w=-1, wa=0, dark_energy_model='fluid') 
cl_GR = results_GR.get_lens_potential_cls(lmax=2550)

# For MG1
pars_MG1.set_dark_energy(w=-1, wa=0, dark_energy_model='fluid') 
cl_MG1 = results_MG1.get_lens_potential_cls(lmax=2550)

print(totCL_GR,totCL_MG1)
print(cl_GR, cl_MG1)
