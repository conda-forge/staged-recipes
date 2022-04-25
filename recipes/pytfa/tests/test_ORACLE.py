# -*- coding: utf-8 -*-
"""
.. module:: skimpy
   :platform: Unix, Windows
   :synopsis: Simple Kinetic Models in Python

.. moduleauthor:: SKiMPy team

[---------]

Copyright 2018 Laboratory of Computational Systems Biotechnology (LCSB),
Ecole Polytechnique Federale de Lausanne (EPFL), Switzerland

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

"""

import pytest

import numpy as np

import pytfa
from pytfa.io import import_matlab_model, load_thermoDB
from pytfa.io.viz import get_reaction_data

from skimpy.utils.namespace import *
from skimpy.sampling.simple_parameter_sampler import SimpleParameterSampler
from skimpy.core.solution import ODESolutionPopulation
from skimpy.io.generate_from_pytfa import FromPyTFA
from skimpy.utils.general import sanitize_cobra_vars
from skimpy.utils.tabdict import TabDict

from skimpy.analysis.oracle import *

from settings import this_directory
from os.path import join

CPLEX = 'optlang-cplex'
GLPK = 'optlang-glpk'

BASL_FLUX = 1e-6  # mmol/gDW/hr
MIN_DISPLACEMENT = 1e-2
SMALL_MOLECULES = ['h_c','h_e','h_m',
                   'h2o2_c','h2o2_e',
                   'co2_c','co2_r','co2_e',' co2_m',
                   'pi_c','pi_r','pi_e','pi_m',
                   'o2_c','o2_r','o2_e','o2_m',
                   'o2s_c', 'o2s_m', 'o2s_e',
                   'ppi_c','ppi_m','ppi_r',
                   'hco3_c','hco3_e','hco3_m',
                   'na1_c','na1_e']

def import_toy_model_from_cobra():
    path_to_model = join(this_directory, '..', 'models/toy_model.mat')

    cobra_model = import_matlab_model(path_to_model)
    #Test the model
    solution = cobra_model.optimize()

    return cobra_model


def convert_cobra_to_tfa(cobra_model):
    """
    Make tfa analysis of the model
    """
    path_to_data = join(this_directory, '..', 'data/thermo_data.thermodb')

    thermo_data = load_thermoDB(path_to_data)

    tmodel= pytfa.ThermoModel(thermo_data, cobra_model)
    # for comp in tmodel.compartments.values():
    #     comp['c_min'] = 1e-8

    tmodel.prepare()
    tmodel.convert(add_displacement = True)

    # Set the solver
    tmodel.solver = GLPK
    # Set solver options
    # GLPK option optimality and integrality deprecated
    #tmodel.solver.configuration.tolerances.optimality = 1e-9
    #tmodel.solver.configuration.tolerances.integrality = 1e-9

    tmodel.solver.configuration.tolerances.feasibility = 1e-9


    # Find a solution
    solution = tmodel.optimize()


    return tmodel


def prepare_tfa_model_for_kinetic_import(tmodel):
    """
    Prepare the model to sample parameters
    """

    # Add minimum flux requirements basal fluxes 1e-6
    # safe: ensure that fluxes that cant obey the minimum requirement are removed

    tmodel = add_min_flux_requirements(tmodel, BASL_FLUX, inplace=True )
    solution = tmodel.optimize()

    # Fix the flux directionality profile (FDP)
    tmodel = fix_directionality(tmodel, solution, inplace=True)
    solution = tmodel.optimize()

    # Add dummy free energy constrains for reaction of unknown free energy
    tmodel = add_undefined_delta_g(tmodel, solution, delta_g_std=0.0, delta_g_std_err=10000.0, inplace=True)
    solution = tmodel.optimize()

    # Force a minimal thermodynamic displacement

    tmodel = add_min_log_displacement(tmodel, MIN_DISPLACEMENT)
    solution = tmodel.optimize()

    return tmodel, solution


def import_kinetic_model_from_tfa(tmodel,solution):

    model_gen = FromPyTFA(small_molecules=SMALL_MOLECULES)
    kmodel = model_gen.import_model(tmodel, solution.raw)

    return kmodel

def get_flux_and_concentration_data(tmodel, solution):
    # Map fluxes back to reaction variables
    this_flux_solution = get_reaction_data(tmodel, solution.raw)
    # Create the flux dict
    # Convert fluxes from mmol/gDW/hr to mol/L/s
    # eColi 0.39 gDW/L
    flux_dict = (0.39*1e-3*this_flux_solution[[i.id for i in tmodel.reactions]]).to_dict()

    # Create a concentration dict with consistent names
    variable_names = tmodel.log_concentration.list_attr('name')
    metabolite_ids = tmodel.log_concentration.list_attr('id')
    #Get conentrations in mol
    temp_concentration_dict = np.exp(solution.raw[variable_names]).to_dict()

    # Map concentration names
    mapping_dict = {k:sanitize_cobra_vars(v) for k,v in zip(variable_names,metabolite_ids)}
    concentration_dict = {mapping_dict[k]:v for k,v in temp_concentration_dict.items()}

    return concentration_dict, flux_dict


"""
Prep and import model
"""
cmodel = import_toy_model_from_cobra()
tmodel = convert_cobra_to_tfa(cmodel)
tmodel, solution = prepare_tfa_model_for_kinetic_import(tmodel)
kmodel = import_kinetic_model_from_tfa(tmodel,solution)
concentration_dict, flux_dict = get_flux_and_concentration_data(tmodel,solution)

def test_compile_mca():
    """
    Compile the model
    """
    kmodel.prepare(mca=True)

    parameter_list = TabDict([(k, p.symbol) for k, p in kmodel.parameters.items()
                              if p.name.startswith('vmax_forward')])

    kmodel.compile_mca(sim_type=QSSA, parameter_list=parameter_list)


@pytest.mark.dependency(name=['test_parameter_sampling_linear_pathway','test_compile_mca'])
def test_oracle_parameter_sampling():

    # Initialize parameter sampler
    sampling_parameters = SimpleParameterSampler.Parameters(n_samples=100)
    sampler = SimpleParameterSampler(sampling_parameters)

    # Sample the model
    parameter_population = sampler.sample(kmodel, flux_dict, concentration_dict)



@pytest.mark.dependency(name=['test_oracle_parameter_sampling','test_compile_mca'])
def test_oracle_flux_concentration_sampling():

    pass



@pytest.mark.dependency(name=['test_oracle_parameter_sampling','test_compile_mca'])
def test_oracle_ode():

    # Initialize parameter sampler
    sampling_parameters = SimpleParameterSampler.Parameters(n_samples=1)
    sampler = SimpleParameterSampler(sampling_parameters)

    # Sample the model
    parameter_population = sampler.sample(kmodel, flux_dict, concentration_dict)


    kmodel.compile_ode(sim_type=QSSA)
    kmodel.initial_conditions = TabDict([(k,v)for k,v in concentration_dict.items()])

    solutions = []
    for parameters in parameter_population:
        kmodel.parameters = parameters
        this_sol_qssa = kmodel.solve_ode(np.linspace(0.0, 10.0, 1000), solver_type='cvode')
        solutions.append(this_sol_qssa)

    this_sol_qssa.plot('test.html')


    solpop = ODESolutionPopulation(solutions)


@pytest.mark.dependency(name=['test_oracle_parameter_sampling','test_compile_mca'])
def test_oracle_mca():


    # Initialize parameter sampler
    sampling_parameters = SimpleParameterSampler.Parameters(n_samples=1)
    sampler = SimpleParameterSampler(sampling_parameters)

    # Sample the model
    parameter_population = sampler.sample(kmodel, flux_dict, concentration_dict)


    """
    Calculate control coefficients 
    """
    flux_control_coeff = kmodel.flux_control_fun(flux_dict,
                                                 concentration_dict,
                                                 parameter_population)

    concentration_control_coeff = kmodel.concentration_control_fun(flux_dict,
                                                                   concentration_dict,
                                                                   parameter_population)


