# -*- coding: utf-8 -*-

"""
This module allows to adjust some parameters according to
the type of execution.

For aster5 cluster.

These asrun customizations are called through (in asrun configuration file) :

    schema_calcul : plugins.aster5.modifier

    schema_execute : plugins.aster5.change_command_line
"""

import os

from asrun.core import magic
from asrun.runner import Runner
from asrun.build import AsterBuild
from asrun.config import build_config_of_version
from asrun.common_func import get_tmpname
from asrun.plugins.generic_func import getCpuParameters, setDistrLimits


# memory (MB) added to memjob for testcases
MEMSUP = 0


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
    setDistrLimits(prof, 512, 200 * 3600 - 1, 'batch')
    return prof

def getCpuParametersLocal(prof):
    """Force to use all available threads for OpenMP AND Blas.
    See `asrun.plugins.generic_func.getCpuParameters` function."""
    # Fix the number of physical processors (2) & cores per processor (12).
    cpu_mpi, node_mpi, cpu_openmp, blas_thread = getCpuParameters(2, 12, prof)
    cpu_openmp = cpu_openmp * blas_thread
    return cpu_mpi, node_mpi, cpu_openmp, blas_thread

def change_batch_parameters(serv, prof):
    """Change the batch parameters in an export object (classe...)."""
    cpu_mpi, node_mpi, cpu_openmp, blas_thread = getCpuParametersLocal(prof)
    cpu_per_node = 1. * cpu_mpi / node_mpi

    # change job queue if :
    #  - it's a study and the batch queue is not defined
    #  - or it's a testcase.
    DEFAULT_QUEUE = 'cn64'
    g0 = group = prof['classe'][0]
    if group == '':
        # by default : prod
        group = DEFAULT_QUEUE
    batch_custom = "--wckey=P11YB:ASTER"

    # add MEMSUP MB
    if not 'distribution' in prof['actions']:
        prof['memjob'] = int(float(prof['memjob'][0])) + MEMSUP * 1024
    if 'astout' in prof['actions']:
        prof['memjob'] = 1000*1024
        prof['tpsjob'] = 60*24
    if cpu_mpi > 1:
        # should allow ncpu=2, node=1 but it does not work.
        batch_custom += ' --exclusive'
        # --nodes is now required, even if it is equal to 1
        if not prof['mpi_nbnoeud'][0]:
            prof['mpi_nbnoeud'] = 1
    else:
        # --nodes must not be set in sequential
        if prof['mpi_nbnoeud'][0]:
            prof['mpi_nbnoeud'] = ""

    memory_limit = float(prof['memjob'][0]) / 1024.
    prof.set_param_memory(memory_limit)
    prof['memoryNode'] = memory_limit * cpu_per_node
    # memory per node in GB
    memGB = memory_limit * cpu_per_node / 1024.
    if memGB > 256:
        group = 'cn512'
    elif memGB > 64:
        group = 'cn256'
    else:
        group = 'cn64'

    # time limit in hour
    tpsjob = float(prof['tpsjob'][0]) * 60. / 3600.
    if tpsjob > 200 and group not in ('cn64', 'urgent'):
        group = 'cn64'

    # special hook for performance testcases with 1 cpu
    if cpu_mpi == 1 and 'performance' in prof['testlist'][0] and memGB < 64:
        batch_custom += ' --exclusive'

    # allocate all the available cores if not given in export
    if not prof['ncpus'][0]:
        magic.run.DBG("Change number of threads: %s" % cpu_openmp)
        # prof['ncpus'] = cpu_openmp
        prof['ncpus'] = min([6, cpu_openmp])
    else:
        prof['ncpus'] = int(prof['ncpus'][0])

    # general - see https://computing.llnl.gov/linux/slurm/cpu_management.html
    batch_custom += (' --cpus-per-task={0} --threads-per-core=1 '
        '--distribution=block:block --mem_bind=local').format(prof['ncpus'][0])

    if g0 == 'urgent':
        batch_custom += ' --qos=urgent'

    prof['batch_custom'] = batch_custom
    if group != g0:
        prof['classe'] = group
        magic.run.DBG("Change batch queue group to : %s" % group)
    return prof


def change_command_line(prof):
    """Change mpirun command line and arguments.
    Argument : ASTER_PROFIL object
    Return value : derivated of Runner class.
    """
    cpu_mpi, node_mpi, cpu_openmp, blas_thread = getCpuParametersLocal(prof)
    # for compatibility with version < 13.1
    use_numthreads = False
    vers = prof['version'][0]
    if vers:
        conf = build_config_of_version(magic.run, vers, error=False)
        if conf:
            build = AsterBuild(magic.run, conf)
            use_numthreads = build.support('use_numthreads')
    if not use_numthreads:
        cpu_openmp = prof['ncpus'][0]
    # end of compatibility block


    class ModifiedRunner(Runner):
        """Modified Runner to export some variables before execution"""

        def get_exec_command(self, cmd_in, add_tee=False, env=None):
            """Return command to run Code_Aster.
            Export specific variables for Intel MKL"""
            cmd = Runner.get_exec_command(self, cmd_in, add_tee, env)
            cmd = (
                "export OMP_NUM_THREADS={openmp} ; "
                "export MKL_NUM_THREADS={blas} ; "
                "export I_MPI_PIN_DOMAIN=omp:compact ; "
            ).format(openmp=cpu_openmp, blas=blas_thread) + cmd
            return cmd

    return ModifiedRunner
