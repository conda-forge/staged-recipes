import pyccl as ccl

cosmo = ccl.Cosmology(
    Omega_c=0.25,
    Omega_b=0.05,
    h=0.7,
    n_s=0.95,
    A_s=2.1e-9,
    transfer_function="boltzmann_camb",
)

print("sigma8:", ccl.sigma8(cosmo))
assert ccl.sigma8(cosmo) > 0.82 and ccl.sigma8(cosmo) < 0.825
