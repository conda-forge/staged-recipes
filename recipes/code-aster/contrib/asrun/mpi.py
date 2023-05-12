"""module renamed in 1.14.0"""
from warnings import warn
warn('moved to asrun.runner', DeprecationWarning, stacklevel=2)
from asrun.runner import *

MPI_INFO = bwc_deprecate_class('MPI_INFO', Runner)
