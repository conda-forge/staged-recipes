#coding: utf-8

"""
Plugin to choose the parallel environment for Sun Grid Engine
batch scheduler.

To enable this plugin, just set in asrun configuration file:

schema_calcul : plugins.sge_pe.modifier

"""

def modifier(calcul):
    """Allows to choose the relevant 'parallel environment'
    Argument : ASTER_CALCUL object
    Return value : ASTER_PROFIL object."""
    prof = calcul.prof
    if prof['mode'][0] == 'batch':
        nbcpu = prof['mpi_nbcpu'][0]
        prof['batch_custom'] = "-pe mpich %s" % nbcpu
    return prof
