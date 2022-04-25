from skimpy.io.yaml import export_to_yaml, load_yaml_model
import os.path
from os.path import join
import pytest

file_dir = os.path.dirname(os.path.abspath(__file__))

###############
# Dummy model #
###############
import numpy as np
from skimpy.core import *
from skimpy.mechanisms import *
from skimpy.analysis.ode.utils import make_flux_fun
from skimpy.utils.namespace import *

name = 'pfk'
metabolites = ReversibleMichaelisMenten.Reactants(substrate = 'A',
                                                   product = 'B')

## QSSA Method
parameters = ReversibleMichaelisMenten.Parameters(
    vmax_forward = 1.0,
    k_equilibrium = 1.5,
    km_substrate = 10.0,
    km_product = 10.0,
    total_enzyme_concentration = 1.0,
)

pfk = Reaction(name=name,
               mechanism = ReversibleMichaelisMenten,
               reactants=metabolites,
               )

dummy_model = KineticModel()
dummy_model.add_reaction(pfk)
dummy_model.parametrize_by_reaction({pfk.name:parameters})

dummy_model_path = 'test.yaml'

#######################################################

@pytest.mark.dependency(name='test_fluxes')
def test_fluxes():
    ## Elementary rate method
    dummy_model.compile_ode(sim_type=ELEMENTARY)

    dummy_model.initial_conditions['A'] = 10.0
    dummy_model.initial_conditions['B'] = 1.0
    dummy_model.initial_conditions['pfk'] = 1.0

    this_sol_full = dummy_model.solve_ode(np.linspace(0.0, 100.0, 1000), solver_type='cvode')

    calc_fluxes = make_flux_fun(dummy_model, ELEMENTARY)

    parameter_values = {k:v.value for k,v in dummy_model.parameters.items()}
    steady_state_fluxes = calc_fluxes(this_sol_full.concentrations.iloc[-1], parameters=parameter_values)


    dummy_model.compile_ode(sim_type=QSSA)

    dummy_model.initial_conditions['A'] = 10.0
    dummy_model.initial_conditions['B'] = 1.0
    dummy_model.initial_conditions['pfk'] = 1.0

    this_sol_full = dummy_model.solve_ode(np.linspace(0.0, 100.0, 1000), solver_type='cvode')

    calc_fluxes = make_flux_fun(dummy_model, QSSA)
    parameter_values = {k:v.value for k,v in dummy_model.parameters.items()}
    steady_state_fluxes = calc_fluxes(this_sol_full.concentrations.iloc[-1], parameters=parameter_values)

def test_export():
    export_to_yaml(dummy_model, dummy_model_path)

def test_cobra_import():
    from skimpy.io.generate_from_cobra import FromCobra
    from cobra.io.mat import load_matlab_model

    this_cobra_model = load_matlab_model(join(file_dir,'..','models','toy_model.mat'), 'model')

    model_gen = FromCobra()
    this_skimpy_model = model_gen.import_model(this_cobra_model)

    # Compile equations
    this_skimpy_model.compile_ode()


@pytest.mark.dependency(depends=['cobra_import'])
def test_import():
    model = load_yaml_model(dummy_model_path)
    model.compile_ode()
