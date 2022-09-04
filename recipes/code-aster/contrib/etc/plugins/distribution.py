# -*- coding: utf-8 -*-

"""Use different parameters for the master run of distributed executions
(parametric or testcases).

By default the parameters of the master run (that dispatch slave executions)
are identical to the slave ones (those entered in astk).

This example only changes limits in batch mode.
"""


from asrun.core import magic
from asrun.plugins.generic_func import setDistrLimits


def modifier(calcul):
    """Adjust the parameters for distributed run.
    Argument : AsterCalcul object
    Return value : AsterProfil object."""
    prof = calcul.prof
    # assign limits of 512 MB and 200 hours in batch mode
    setDistrLimits(prof, 512, 200 * 3600 - 1, 'batch')
    # uncomment if needed in interactive mode
    # setDistrLimits(prof, 512, 24 * 3600 - 1, 'interactif')
    return prof
