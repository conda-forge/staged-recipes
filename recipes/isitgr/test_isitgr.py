#!/use/bin/env python

# check that we are not linking fast-math from fortran
str_num_before = str(1e-323)
print("before import:", str_num_before)

import isitgr

str_num_after = str(1e-323)
print("after import:", str_num_after)

assert str_num_before == str_num_after

# run the code
pars_GR = isitgr.CAMBparams()
pars_GR.set_cosmology(
    H0=67.5, ombh2=0.022, omch2=0.122, mnu=0.06, omk=0, tau=0.06)
pars_GR.InitPower.set_params(As=2e-9, ns=0.965, r=0)
pars_GR.set_for_lmax(2500, lens_potential_accuracy=0)
pars_GR.set_matter_power(redshifts=[0.0], kmax=2.0)
results_GR = isitgr.get_results(pars_GR)
results_GR.calc_power_spectra(pars_GR)

pars_MG = isitgr.CAMBparams()
pars_MG.set_cosmology(
    H0=67.5, ombh2=0.022, omch2=0.122, mnu=0.06, omk=0, tau=0.06, parameterization="mueta", E11=1, E22=1)
pars_MG.InitPower.set_params(As=2e-9, ns=0.965, r=0)
pars_MG.set_for_lmax(2500, lens_potential_accuracy=0)
pars_MG.set_matter_power(redshifts=[0.0], kmax=2.0)
results_MG = isitgr.get_results(pars_MG)
results_MG.calc_power_spectra(pars_MG)


# compute sigma8 and make sure it is ok
sigma8_GR = results_GR.get_sigma8()
sigma8_MG = results_MG.get_sigma8()
assert sigma8_GR > 0.80 and sigma8_GR < 0.805
assert sigma8_GR<sigma8_MG
print(sigma8_GR, sigma8_MG)
