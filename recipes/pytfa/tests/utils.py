from skimpy.core import Reaction, KineticModel, ConstantConcentration
from skimpy.mechanisms import ReversibleMichaelisMenten


def build_linear_pathway_model():
    # Build linear Pathway model
    metabolites_1 = ReversibleMichaelisMenten.Reactants(substrate='A', product='B')
    metabolites_2 = ReversibleMichaelisMenten.Reactants(substrate='B', product='C')
    metabolites_3 = ReversibleMichaelisMenten.Reactants(substrate='C', product='D')

    ## QSSA Method
    parameters_1 = ReversibleMichaelisMenten.Parameters(k_equilibrium=1.5)
    parameters_2 = ReversibleMichaelisMenten.Parameters(k_equilibrium=2.0)
    parameters_3 = ReversibleMichaelisMenten.Parameters(k_equilibrium=3.0)

    reaction1 = Reaction(name='E1',
                         mechanism=ReversibleMichaelisMenten,
                         reactants=metabolites_1,
                         )

    reaction2 = Reaction(name='E2',
                         mechanism=ReversibleMichaelisMenten,
                         reactants=metabolites_2,
                         )

    reaction3 = Reaction(name='E3',
                         mechanism=ReversibleMichaelisMenten,
                         reactants=metabolites_3,
                         )

    this_model = KineticModel()
    this_model.add_reaction(reaction1)
    this_model.add_reaction(reaction2)
    this_model.add_reaction(reaction3)

    the_boundary_condition = ConstantConcentration(this_model.reactants['A'])
    this_model.add_boundary_condition(the_boundary_condition)

    the_boundary_condition = ConstantConcentration(this_model.reactants['D'])
    this_model.add_boundary_condition(the_boundary_condition)

    this_model.parametrize_by_reaction({'E1': parameters_1,
                                        'E2': parameters_2,
                                        'E3': parameters_3})
    return this_model

