import pytest
# Test models
from skimpy.sampling.simple_parameter_sampler import SimpleParameterSampler
from skimpy.utils.namespace import *
from tests.utils import build_linear_pathway_model



@pytest.mark.dependency(name='build_linear_pathway_model')
def test_parameter_sampling_linear_pathway():
    this_model = build_linear_pathway_model()

    this_model.prepare(mca=True)
    this_model.compile_mca(sim_type = QSSA)


    flux_dict = {'E1': 1.0, 'E2': 1.0, 'E3': 1.0}
    concentration_dict = {'A': 10.0, 'B': 5.0, 'C': 1.0, 'D': 0.05}

    parameters = SimpleParameterSampler.Parameters(n_samples=10)
    sampler = SimpleParameterSampler(parameters)

    parameter_population_A = sampler.sample(this_model, flux_dict,
                                          concentration_dict, seed = 10)

    parameter_population_B = sampler.sample(this_model, flux_dict,
                                          concentration_dict, seed = 10)

    parameter_population_C = sampler.sample(this_model, flux_dict,
                                          concentration_dict, seed = 20)

    assert(parameter_population_A == parameter_population_B)
    assert( not(parameter_population_B == parameter_population_C))