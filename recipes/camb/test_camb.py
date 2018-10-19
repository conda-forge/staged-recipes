#!/use/bin/env python
import camb

# run the code
pars = camb.CAMBparams()
pars.set_cosmology(
    H0=67.5, ombh2=0.022, omch2=0.122, mnu=0.06, omk=0, tau=0.06)
pars.InitPower.set_params(As=2e-9, ns=0.965, r=0)
pars.set_for_lmax(2500, lens_potential_accuracy=0)
pars.set_matter_power(redshifts=[0.0], kmax=2.0)
results = camb.get_results(pars)
results.calc_power_spectra(pars)

# compute sigma8 and make sure it is ok
sigma8 = results.get_sigma8()
assert sigma8 > 0.80 and sigma8 < 0.805
