# -*- coding: utf-8 -*-

"""
This module allows to adjust some parameters according to
the type of execution.

For Ivanoe cluster.

These asrun customizations are called through (in asrun configuration file) :

    schema_calcul : plugins.ivanoe.modifier

This one is not used in production:
    schema_execute : plugins.ivanoe.change_command_line
"""

import os
from math import ceil

from asrun.core import magic
from asrun.runner import Runner
from asrun.common_func  import get_tmpname

# memory (MB) added to memjob for testcases
MEMSUP = 0
def iceil(x):
    return int(ceil(x))


def modifier(calcul):
    """Call elementary functions to adjust :
        - batch parameters,
        - TODO submit interactive mpi execution in interactive queues.
    Argument : ASTER_CALCUL object
    Return value : ASTER_PROFIL object."""
    serv = calcul.serv
    prof = calcul.prof
    if prof['mode'][0] == 'batch':
        prof = change_batch_parameters(serv, prof)
    return prof


def change_batch_parameters(serv, prof):
    """Change the batch parameters in an export object (classe...)."""
    # available services are defined in calcul.py :

    cpu_mpi, node_mpi, cpu_openmp, blas_thread = _get_cpu_parameters(prof)

    # change job queue if :
    #  - it's a study and the batch queue is not defined
    #  - or it's a testcase.
    DEFAULT_QUEUE = 'seq'
    g0 = group = prof['classe'][0]
    if group == '':
        # by default : prod
        group = DEFAULT_QUEUE

    # add MEMSUP MB
    if not 'distribution' in prof['actions']:
        prof['memjob'] = int(float(prof['memjob'][0])) + MEMSUP * 1024
    if 'astout' in prof['actions']:
        prof['memjob'] = 1000*1024
        prof['tpsjob'] = 60*24
    if cpu_mpi > 1:
        # should allow ncpu=2, node=1 but it does not work.
        prof['batch_custom'] = '--overcommit --exclusive'
        group = 'par'

    if group != g0 and g0 != "bmem" and g0 != "visu":
        prof['classe'] = group
        magic.run.DBG("Change batch queue group to : %s" % group)
    return prof

def change_command_line(prof):
    """Change mpirun command line and arguments."""

    class ModifiedRunner(Runner):
        def __init__(self, *args, **kwargs):
            Runner.__init__(self, *args, **kwargs)
            self._prof = prof

        def set_rep_trav(self, reptrav, basename=''):
            """Set temporary directory for Code_Aster executions."""
            # WARNING: experimental, /dev/shm is not guaranted to be big enough!
            Runner.set_rep_trav(self, reptrav, basename='')
            run = magic.run
            run.DBG("IN global_reptrav set to %s" % self.global_reptrav,
                    "IN local_reptrav  set to %s" % self.local_reptrav)
            if not reptrav:
                if self.really():   # for a MPI execution
                    self.local_reptrav = dirn = get_tmpname(run, '/dev/shm', basename)
                run.DBG("OUT global_reptrav set to %s" % self.global_reptrav,
                        "OUT local_reptrav  set to %s" % self.local_reptrav)
            return self.global_reptrav

        def really(self):
            """Return True if Code_Aster executions need mpirun."""
            return self._use_mpi and self.nbcpu() > 1

    return ModifiedRunner


def _get_cpu_parameters(prof):
    """Return number of OpenMP threads, MPI cpus and MPI nodes
    asked in the export."""
    try:
        cpu_openmp = int(prof['ncpus'][0] or 1)
    except ValueError:
        cpu_openmp = 1
    cpu_openmp = max(cpu_openmp, 1)
    try:
        cpu_mpi = int(prof['mpi_nbcpu'][0] or 1)
    except ValueError:
        cpu_mpi = 1
    cpu_mpi = max(cpu_mpi, 1)
    node_mpi = 999999
    try:
        node_mpi = int(prof['mpi_nbnoeud'][0]) or node_mpi
    except ValueError:
        pass
    return adjust_cpu_parameters(cpu_mpi, node_mpi, cpu_openmp)

def adjust_cpu_parameters(cpu_mpi, node_mpi, cpu_openmp):
    """Adjust the number of processors, nodes to optimize the
    utilization of resources and performances."""
    #print ">>> Requested (cpu_mpi / node / openmp) :", cpu_mpi, node_mpi, cpu_openmp
    PHYSICAL_PROC = 2  # number of physical processors
    CORE_PER_PROC = 6  # number of cores on each processor

    cpu_per_node = iceil(1. * cpu_mpi / node_mpi)
    # use at least PHYSICAL_PROC procs per node
    if cpu_per_node < PHYSICAL_PROC:
        cpu_per_node = PHYSICAL_PROC
    # do not allocate more nodes than necessary
    if node_mpi > 1. * cpu_mpi / cpu_per_node:
        node_mpi = iceil(1. * cpu_mpi / cpu_per_node)
    # because the nodes are exclusive, use all the processors (if cpu_mpi > 1)
    if cpu_mpi > 1 and cpu_mpi < node_mpi * PHYSICAL_PROC:
        cpu_mpi = node_mpi * PHYSICAL_PROC

    # recommandations
    if cpu_per_node > PHYSICAL_PROC:
        print("Warning: more MPI processors per node (%d) than physical processors (%d)." \
            % (cpu_per_node, PHYSICAL_PROC))
    # not yet used and usable
    thread_per_cpu = PHYSICAL_PROC * CORE_PER_PROC / cpu_per_node
    blas_thread = max(thread_per_cpu / cpu_openmp, 1)
    if cpu_openmp * blas_thread * cpu_per_node > PHYSICAL_PROC * CORE_PER_PROC:
        print("Warning: more threads (%d) than cores (%d)." \
            % (cpu_openmp * blas_thread * cpu_per_node, PHYSICAL_PROC * CORE_PER_PROC))
    #print "    return (cpu_mpi / node / cpu_per_node / openmp / blas) :", \
        #cpu_mpi, node_mpi, cpu_per_node, cpu_openmp, blas_thread
    #print
    return cpu_mpi, node_mpi, cpu_openmp, blas_thread



# unittest
if __name__ == '__main__':
    res = adjust_cpu_parameters(1, 5, 1)  # seq
    assert res == (1, 1, 1, 4), res
    res = adjust_cpu_parameters(8, 999999, 1)
    assert res == (8, 4, 1, 4), res
    res = adjust_cpu_parameters(12, 3, 1)
    assert res == (12, 3, 1, 2), res
    res = adjust_cpu_parameters(13, 8, 1)
    assert res == (14, 7, 1, 4), res
    res = adjust_cpu_parameters(11, 11, 1)
    assert res == (12, 6, 1, 4), res
    res = adjust_cpu_parameters(9, 2, 4)
    assert res == (9, 2, 4, 1), res
    res = adjust_cpu_parameters(17, 3, 2)
    assert res == (17, 3, 2, 1), res
