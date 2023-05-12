# -*- coding: utf-8 -*-

"""
This module allows to consult execution output clusters, in parallel case
only output of processor 0 is shown.
A regular expression could be used to search only matching lines of output.

These asrun customizations are called through (in asrun configuration file) :

    schema_tail_exec :  plugins.tail_slurm.tail

"""

from asrun.core import magic
from asrun.common_func import flash_filename
from asrun.job import Func_actu


def tail(run, jobid, jobname, mode, nbline, expression=None):
    """Custom the tail function by reading the output in flash directory"""
    # keep output of proc0 only
    etat, diag, node, tcpu, wrk, queue = Func_actu(run, jobid, jobname, mode)
    jret = 0
    s_out = ''
    if etat == 'RUN':
        cmd = "egrep -v -- '^\[[1-9][0-9]*\]' {fich}"
        if expression is None or expression.strip() == "":
            cmd += " | tail -{nbline}"
        else:
            cmd += " | egrep -- '{expression}'"
        fich = flash_filename("flasheur", jobname, jobid, "output")
        if run.Exists(fich):
            jret, s_out = run.Shell(cmd.format(**locals()), mach="")
    return etat, diag, s_out
