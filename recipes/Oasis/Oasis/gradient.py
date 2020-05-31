"""
gradient

Holds the Python Design Optimization Gradient Calculation Class.

"""

__version__ = '$Revision: $'



#import os, sys
import copy
#import pdb


import numpy


eps = 1.0  # define a value for machine precision
while ((eps / 2.0 + 1.0) > 1.0):
    eps = eps / 2.0

eps = 2.0 * eps



class Gradient(object):
    """
    Abstract Class for Optimizer Gradient Calculation Object
    """

    def __init__(self, opt_problem, sens_type, sens_mode='', sens_step={}, *args, **kwargs):

        """
        Optimizer Gradient Calculation Class Initialization

        Arguments:

        - opt_problem -> INST: Optimization instance
        - sens_type -> STR/FUNC: Sensitivity type ('FD', 'CS', or function)

        Keyword arguments:

        - sens_mode -> STR: Parallel flag [''-serial,'pgc'-parallel], *Default* = ''
        - sens_step -> INT: Step size, *Default* = {} [=1e-6(FD), 1e-20(CS)]
        """

        self.opt_problem = opt_problem
        if isinstance(sens_type, str):
            self.sens_type = sens_type.lower()
        else:
            self.sens_type = sens_type

        if (sens_step == {}):
            if (self.sens_type == 'fd'):
                self.sens_step = 1.0e-6
            elif (self.sens_type == 'cs'):
                self.sens_step = 1.0e-20
            else:
                self.sens_step = sens_step

        else:
            self.sens_step = sens_step

        self.sens_mode = sens_mode.lower()

        # MPI Setup
        if (self.sens_mode.lower() == 'pgc'):
            try:
                import mpi4py
                from mpi4py import MPI
            except ImportError:
                print('Error: mpi4py library failed to import')

            comm = MPI.COMM_WORLD
            self.nproc = comm.Get_size()
            self.myrank = comm.Get_rank()
            if (mpi4py.__version__[0] == '0'):
                self.Barrier = comm.Barrier
                self.Send = comm.SSend
                self.Recv = comm.Recv
                self.Bcast = comm.Bcast
                self.Gather = comm.Gather
            elif (mpi4py.__version__[0] >= '1'):
                self.Barrier = comm.barrier
                self.Send = comm.ssend
                self.Recv = comm.recv
                self.Bcast = comm.bcast
                self.Gather = comm.gather

            self.mydvs = range(self.myrank,
                               len(opt_problem._variables.keys()),
                               self.nproc)
        else:
            self.myrank = 0
            self.mydvs = range(len(opt_problem._variables.keys()))

    def getGrad(self, x, group_ids, f, g, *args, **kwargs):
        """
        Get Gradient

        Arguments:

        - x -> ARRAY: Design variables
        - group_ids -> DICT: Group identifications
        - f -> ARRAY: Objective values
        - g -> ARRAY: Constraint values
        """

        opt_problem = self.opt_problem
        sens_type = self.sens_type
        sens_mode = self.sens_mode
        sens_step = self.sens_step
        mydvs = self.mydvs
        myrank = self.myrank

        opt_problem.is_gradient = True

        dfi = numpy.zeros([len(opt_problem._objectives.keys()), len(mydvs)], 'd')
        dgi = numpy.zeros([len(opt_problem._constraints.keys()), len(mydvs)], 'd')

        if (sens_type == 'fd'):

            # Finite Differences
            dh = sens_step
            xs = x
            k = 0
            for i in mydvs:
                xh = copy.copy(xs)
                xh[i] += dh

                # Variables Groups Handling
                if opt_problem.use_groups:
                    xhg = {}
                    for group in group_ids.keys():
                        if (group_ids[group][1] - group_ids[group][0] == 1):
                            xhg[group] = xh[group_ids[group][0]]
                        else:
                            xhg[group] = xh[group_ids[group][0]:group_ids[group][1]]

                    xh = xhg

                [fph, gph, fail] = opt_problem.obj_fun(xh, *args, **kwargs)
                if isinstance(fph, float):
                    fph = [fph]

                for j in range(len(opt_problem._objectives.keys())):
                    dfi[j, k] = (fph[j] - f[j]) / dh

                for j in range(len(opt_problem._constraints.keys())):
                    dgi[j, k] = (gph[j] - g[j]) / dh

                k += 1

        elif (sens_type == 'cs'):

            # Complex Step
            cdh = sens_step
            cxs = copy.copy(x)
            k = 0
            for i in mydvs:
                cxh = cxs + numpy.zeros(len(cxs), complex)
                cxh[i] = complex(cxh[i], cdh)

                # Variables Groups Handling
                if opt_problem.use_groups:
                    cxhg = {}
                    for group in group_ids.keys():
                        if (group_ids[group][1] - group_ids[group][0] == 1):
                            cxhg[group] = cxh[group_ids[group][0]]
                        else:
                            cxhg[group] = cxh[group_ids[group][0]:group_ids[group][1]]

                    cxh = cxhg

                [cfph, cgph, fail] = opt_problem.obj_fun(cxh, *args, **kwargs)
                if isinstance(cfph, complex):
                    cfph = [cfph]

                for j in range(len(opt_problem._objectives.keys())):
                    dfi[j, k] = cfph[j].imag / cdh

                for j in range(len(opt_problem._constraints.keys())):
                    dgi[j, k] = cgph[j].imag / cdh

                k += 1

            dfi = dfi.astype(float)
            dgi = dgi.astype(float)

        else:

            # Variables Groups Handling
            if opt_problem.use_groups:
                xg = {}
                for group in group_ids.keys():
                    if (group_ids[group][1] - group_ids[group][0] == 1):
                        xg[group] = x[group_ids[group][0]]
                    else:
                        xg[group] = x[group_ids[group][0]:group_ids[group][1]]

                xn = xg
            else:
                xn = x

            # User Provided Sensitivities
            [df_user, dg_user, fail] = sens_type(xn, f, g, *args, **kwargs)

            if isinstance(df_user, list):
                if len(opt_problem._objectives.keys()) == 1:
                    df_user = [df_user]

                df_user = numpy.array(df_user)

            if isinstance(dg_user, list):
                dg_user = numpy.array(dg_user)

            #
            for i in range(len(opt_problem._variables.keys())):
                for j in range(len(opt_problem._objectives.keys())):
                    dfi[j, i] = df_user[j, i]

                for j in range(len(opt_problem._constraints.keys())):
                    dgi[j, i] = dg_user[j, i]

        # MPI Gradient Assembly
        df = numpy.zeros([
            len(opt_problem._objectives.keys()), len(
                opt_problem._variables.keys())
        ], 'd')
        dg = numpy.zeros([
            len(opt_problem._constraints.keys()), len(
                opt_problem._variables.keys())
        ], 'd')
        if (sens_mode == 'pgc'):
            if (sens_type == 'fd') or (sens_type == 'cs'):
                send_obj = [myrank, dfi, dgi]
                p_results = self.Gather(send_obj, root=0)

                if myrank == 0:
                    for proc in range(self.nproc):
                        k = 0
                        for i in range(p_results[proc][0],
                                       len(opt_problem._variables.keys()),
                                       self.nproc):
                            df[:, i] = p_results[proc][1][:, k]
                            dg[:, i] = p_results[proc][2][:, k]
                            k += 1

            [df, dg] = self.Bcast([df, dg], root=0)

        else:
            df = dfi
            dg = dgi

        opt_problem.is_gradient = False

        return df, dg

    def getHess(self, *args, **kwargs):
        """
        Get Hessian
        """

        return



# Optimizer Gradient Calculation Test
if __name__ == '__main__':

    # Test Optimizer Gradient Calculation
    print('Testing Optimizer Gradient Calculation...')
    grd = Gradient()
