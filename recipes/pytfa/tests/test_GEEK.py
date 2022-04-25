import pytest
# Test models
from skimpy.core import *
from skimpy.mechanisms import *
import numpy as np


def build_linear_GEEK_pathway_model():

    metabolites = ['A', 'B', 'C', 'D' ]
    # Build linear Pathway model
    UniUniGEEK = make_generalized_elementary_kinetics([-1,1], metabolites)
    metabolites_1 = UniUniGEEK.Reactants(substrate1='A', product1='B')
    metabolites_2 = UniUniGEEK.Reactants(substrate1='B', product1='C')
    metabolites_3 = UniUniGEEK.Reactants(substrate1='C', product1='D')

    # FIXME: Currently the Inhibitors are constructed as new reactant set instead resulting in redefinition of already
    # defined metabolites. This is not very nice ...
    inhibitors = UniUniGEEK.Inhibitors(**dict(zip(metabolites,metabolites)))

    reaction1 = Reaction(name='E1',
                         mechanism=UniUniGEEK,
                         reactants=metabolites_1,
                         inhibitors=inhibitors
                         )

    reaction2 = Reaction(name='E2',
                         mechanism=UniUniGEEK,
                         reactants=metabolites_2,
                         inhibitors=inhibitors
                         )

    reaction3 = Reaction(name='E3',
                         mechanism=UniUniGEEK,
                         reactants=metabolites_3,
                         inhibitors=inhibitors
                         )


    parameters_1 = UniUniGEEK.Parameters(k_equilibrium=1.5,
                                         vmax_forward=1.0,
                                         A_0=1.0,
                                         B_0=1.0,
                                         C_0=1.0,
                                         D_0=1.0,
                                         alpha_forward_A=0.1,
                                         alpha_forward_B=0.1,
                                         alpha_forward_C=0.1,
                                         alpha_forward_D=0.1,
                                         alpha_reverse_A=0.1,
                                         alpha_reverse_B=0.1,
                                         alpha_reverse_C=0.1,
                                         alpha_reverse_D=0.1,
                                         beta_forward=0.1,
                                         beta_reverse=0.1
                                         )

    parameters_2 = UniUniGEEK.Parameters(k_equilibrium=2.0,
                                         vmax_forward=1.0,
                                         A_0=1.0,
                                         B_0=1.0,
                                         C_0=1.0,
                                         D_0=1.0,
                                         alpha_forward_A=0.1,
                                         alpha_forward_B=0.1,
                                         alpha_forward_C=0.1,
                                         alpha_forward_D=0.1,
                                         alpha_reverse_A=0.1,
                                         alpha_reverse_B=0.1,
                                         alpha_reverse_C=0.1,
                                         alpha_reverse_D=0.1,
                                         beta_forward=0.1,
                                         beta_reverse=0.1
                                         )

    parameters_3 = UniUniGEEK.Parameters(k_equilibrium=3.0,
                                         vmax_forward=1.0,
                                         A_0=1.0,
                                         B_0=1.0,
                                         C_0=1.0,
                                         D_0=1.0,
                                         alpha_forward_A=0.1,
                                         alpha_forward_B=0.1,
                                         alpha_forward_C=0.1,
                                         alpha_forward_D=0.1,
                                         alpha_reverse_A=0.1,
                                         alpha_reverse_B=0.1,
                                         alpha_reverse_C=0.1,
                                         alpha_reverse_D=0.1,
                                         beta_forward=0.1,
                                         beta_reverse=0.1
                                         )


    this_model = KineticModel()
    this_model.add_reaction(reaction1)
    this_model.add_reaction(reaction2)
    this_model.add_reaction(reaction3)

    # FIXME Current solution for fixme above
    this_model.repair()

    the_boundary_condition = ConstantConcentration(this_model.reactants['A'])
    this_model.add_boundary_condition(the_boundary_condition)

    the_boundary_condition = ConstantConcentration(this_model.reactants['D'])
    this_model.add_boundary_condition(the_boundary_condition)

    this_model.parametrize_by_reaction({'E1': parameters_1,
                                        'E2': parameters_2,
                                        'E3': parameters_3})
    return this_model



def test_geek_kinetics():
    this_model = build_linear_GEEK_pathway_model()

    concentration_dict = {'A': 3.0, 'B': 2.0, 'C': 1.0, 'D': 0.5}

    this_model.parameters.A.value = 3.0
    this_model.parameters.D.value = 0.5

    this_model.compile_ode(sim_type=QSSA)




    for c,v in concentration_dict.items():
        this_model.initial_conditions[c]=v

    this_model.solve_ode(time_out=np.linspace(0,100,1000))
