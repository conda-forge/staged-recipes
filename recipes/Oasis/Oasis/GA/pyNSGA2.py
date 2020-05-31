"""
pyNSGA2 - A Python pyOpt interface to NSGA-II.
"""

__version__ = '$Revision: $'

try:
        from . import nsga2
except:
        raise ImportError('NSGA-II shared library failed to import')


import os, sys
import copy, time
import numpy
from pyOpt import Optimizer


inf = 10.E+20

eps = 1.0
while ((eps/2.0 + 1.0) > 1.0):
        eps = eps/2.0

eps = 2.0*eps


class NSGA2(Optimizer):

        '''
        NSGA2 Optimizer Class - Inherited from Optimizer Abstract Class
        '''

        def __init__(self, pll_type=None, *args, **kwargs):

                '''
                NSGA2 Optimizer Class Initialization

                **Keyword arguments:**

                - pll_type -> STR: Parallel Implementation (None, 'POA'-Parallel Objective Analysis), *Default* = None

                Documentation last updated:  Feb. 16, 2010 - Peter W. Jansen
                '''

                if (pll_type == None):
                        self.poa = False
                elif (pll_type.upper() == 'POA'):
                        self.poa = True
                else:
                        raise ValueError("pll_type must be either None or 'POA'")

                name = 'NSGA-II'
                category = 'Global Optimizer'
                def_opts = {
                    'PopSize': [int, 100],
                    'maxGen': [int, 150],
                    'pCross_real': [float, 0.6],
                    'pMut_real': [float, 0.2],
                    'eta_c': [float, 10],
                    'eta_m': [float, 20],
                    'pCross_bin': [float, 0],
                    'pMut_bin': [float, 0],
                    # Flag to Turn On Output to filename (0 - , 1 - , 2 - )
                    'PrintOut': [int, 1],
                    # Random Number Seed (0 - Auto-Seed based on time clock)
                    'seed': [float, 0],
                    # Use Initial Solution Flag (0 - random population, 1 - use given solution)
                    'xinit': [int, 0],
                }
                informs = {}
                Optimizer.__init__(self, name, category, def_opts, informs, *args, **kwargs)


        def __solve__(self, opt_problem={}, store_sol=True, disp_opts=False, store_hst=False, hot_start=False, *args, **kwargs):
                '''
                Run Optimizer (Optimize Routine)

                **Keyword arguments:**

                - opt_problem -> INST: Optimization instance
                - store_sol -> BOOL: Store solution in Optimization class flag, *Default* = True
                - disp_opts -> BOOL: Flag to display options in solution text, *Default* = False
                - store_hst -> BOOL/STR: Flag/filename to store optimization history, *Default* = False
                - hot_start -> BOOL/STR: Flag/filename to read optimization history, *Default* = False

                Additional arguments and keyword arguments are passed to the objective function call.

                Documentation last updated:  February. 16, 2011 - Peter W. Jansen
                '''

                if self.poa:
                        try:
                                import mpi4py
                                from mpi4py import MPI
                        except ImportError:
                                print('pyNSGA-II: Parallel objective Function Analysis requires mpi4py')

                        comm = MPI.COMM_WORLD
                        nproc = comm.Get_size()
                        if (mpi4py.__version__[0] == '0'):
                                Barrier = comm.Barrier
                                Send = comm.Send
                                Recv = comm.Recv
                                Bcast = comm.Bcast
                        elif (mpi4py.__version__[0] >= '1'):
                                Barrier = comm.barrier
                                Send = comm.send
                                Recv = comm.recv
                                Bcast = comm.bcast

                        self.pll = True
                        self.myrank = comm.Get_rank()
                else:
                        self.pll = False
                        self.myrank = 0


                myrank = self.myrank

                def_fname = 'nsga2'
                hos_file, log_file, tmp_file = self._setHistory(opt_problem.name, store_hst, hot_start, def_fname)


                # NSGA-II - Objective/Constraint Values Function
                def objconfunc(nreal,nobj,ncon,x,f,g):

                        # Variables Groups Handling
                        if opt_problem.use_groups:
                                xg = {}
                                for group in group_ids.keys():
                                        if (group_ids[group][1]-group_ids[group][0] == 1):
                                                xg[group] = x[group_ids[group][0]]
                                        else:
                                                xg[group] = x[group_ids[group][0]:group_ids[group][1]]

                                xn = xg
                        else:
                                xn = x

                        # Evaluate User Function
                        fail = 0
                        ff = []
                        gg = []
                        if (myrank == 0):
                                if self.hot_start:
                                        [vals,hist_end] = hos_file.read(ident=['obj', 'con', 'fail'])
                                        if hist_end:
                                                self.hot_start = False
                                                hos_file.close()
                                        else:
                                                [ff,gg,fail] = [vals['obj'][0][0],vals['con'][0],int(vals['fail'][0][0])]

                        if self.pll:
                                self.hot_start = Bcast(self.hot_start,root=0)

                        if self.hot_start and self.pll:
                                [ff,gg,fail] = Bcast([ff,gg,fail],root=0)
                        elif not self.hot_start:
                                [ff,gg,fail] = opt_problem.obj_fun(xn, *args, **kwargs)

                        # Store History
                        if (myrank == 0):
                                if self.sto_hst:
                                        log_file.write(x,'x')
                                        log_file.write(ff,'obj')
                                        log_file.write(gg,'con')
                                        log_file.write(fail,'fail')

                        if (fail == 1):
                                # Objective Assigment
                                for i in range(len(opt_problem._objectives.keys())):
                                        f[i] = inf

                                # Constraints Assigment
                                for i in range(len(opt_problem._constraints.keys())):
                                        g[i] = -inf

                        else:
                                # Objective Assigment
                                if (len(opt_problem._objectives.keys()) == 1):
                                        f[0] = ff
                                else:
                                        for i in range(len(opt_problem._objectives.keys())):
                                                if isinstance(ff[i],complex):
                                                        f[i] = ff[i].astype(float)
                                                else:
                                                        f[i] = ff[i]



                                # Constraints Assigment
                                for i in range(len(opt_problem._constraints.keys())):
                                        if isinstance(gg[i],complex):
                                                g[i] = -gg[i].astype(float)
                                        else:
                                                g[i] = -gg[i]

                        return f,g


                # Variables Handling
                n = len(opt_problem._variables.keys())
                x = nsga2.new_doubleArray(n)
                xl = nsga2.new_doubleArray(n)
                xu = nsga2.new_doubleArray(n)
                i = 0
                for key in opt_problem._variables.keys():
                        if (opt_problem._variables[key].type == 'c'):
                                nsga2.doubleArray_setitem(x,i,opt_problem._variables[key].value)
                                nsga2.doubleArray_setitem(xl,i,opt_problem._variables[key].lower)
                                nsga2.doubleArray_setitem(xu,i,opt_problem._variables[key].upper)
                        elif (opt_problem._variables[key].type == 'i'):
                                raise IOError('Current NSGA-II cannot handle integer design variables')
                        elif (opt_problem._variables[key].type == 'd'):
                                raise IOError('Current NSGA-II cannot handle discrete design variables')
                        i += 1

                # Variables Groups Handling
                if opt_problem.use_groups:
                        group_ids = {}
                        k = 0
                        for key in opt_problem._vargroups.keys():
                                group_len = len(opt_problem._vargroups[key]['ids'])
                                group_ids[opt_problem._vargroups[key]['name']] = [k,k+group_len]
                                k += group_len

                # Constraints Handling
                m = len(opt_problem._constraints.keys())
                me = 0
                g = nsga2.new_doubleArray(m)
                #j = 0
                if m > 0:
                        for key in opt_problem._constraints.keys():
                                if opt_problem._constraints[key].type == 'e':
                                        raise IOError('Current NSGA-II cannot handle equality constraints')

                                #nsga2.doubleArray_setitem(g,j,opt_problem._constraints[key].value)
                        #j += 1

                # Objective Handling
                objfunc = opt_problem.obj_fun
                l = len(opt_problem._objectives.keys())
                f = nsga2.new_doubleArray(l)
                #k = 0
                #for key in opt_problem._objectives.keys():
                #       nsga2.doubleArray_setitem(f,k,opt_problem._objectives[key].value)
                #       k += 1

                # Setup argument list values
                nfeval = 0
                popsize = self.options['PopSize'][1]
                if popsize % 4 > 0:
                    raise IOError("PopSize needs to be a multiple of 4 for NSGA2!")
                ngen = self.options['maxGen'][1]
                pcross_real = self.options['pCross_real'][1]
                pmut_real = self.options['pMut_real'][1]
                eta_c = self.options['eta_c'][1]
                eta_m = self.options['eta_m'][1]
                pcross_bin = self.options['pCross_bin'][1]
                pmut_bin = self.options['pMut_bin'][1]
                if (self.options['PrintOut'][1]>=0 and self.options['PrintOut'][1]<=2):
                        printout = self.options['PrintOut'][1]
                else:
                        raise IOError('Incorrect Stopping Criteria Setting')

                seed = self.options['seed'][1]
                if (seed == 0) and not self.hot_start:
                        seed = time.time() / 2147483647   # must be number between 0 and 1
                if self.hot_start:
                        seed = hos_file.read(-1,ident=['seed'])[0]['seed'][0][0]

                #if self.pll:
                #        seed = Bcast(seed, root=0)

                if self.sto_hst and (myrank == 0):
                        log_file.write(seed,'seed')

                xinit = self.options['xinit'][1]

                # Run NSGA-II
                nsga2.set_pyfunc(objconfunc)
                t0 = time.time()

                nsga2.nsga2(n,m,l,f,x,g,nfeval,xl,xu,popsize,ngen,pcross_real,
                        pmut_real,eta_c,eta_m,pcross_bin,pmut_bin,printout,seed,xinit)


                sol_time = time.time() - t0

                if (myrank == 0):
                        if self.sto_hst:
                                log_file.close()
                                if tmp_file:
                                        hos_file.close()
                                        name = hos_file.filename
                                        os.remove(name+'.cue')
                                        os.remove(name+'.bin')
                                        os.rename(name+'_tmp.cue',name+'.cue')
                                        os.rename(name+'_tmp.bin',name+'.bin')

                # Store Results
                if store_sol:
                        sol_name = 'NSGA-II Solution to ' + opt_problem.name

                        sol_options = copy.copy(self.options)
                        if 'defaults' in sol_options:
                                del sol_options['defaults']

                        sol_inform = {}
                        #sol_inform['value'] = inform
                        #sol_inform['text'] = self.getInform(inform)

                        sol_evals = nfeval

                        sol_vars = copy.deepcopy(opt_problem._variables)
                        i = 0
                        for key in sol_vars.keys():
                                sol_vars[key].value = nsga2.doubleArray_getitem(x,i)
                                i += 1

                        sol_objs = copy.deepcopy(opt_problem._objectives)
                        i = 0
                        for key in sol_objs.keys():
                                sol_objs[key].value = nsga2.doubleArray_getitem(f,i)
                                i += 1

                        if m > 0:
                                sol_cons = copy.deepcopy(opt_problem._constraints)
                                i = 0
                                for key in sol_cons.keys():
                                        sol_cons[key].value = -nsga2.doubleArray_getitem(g,i)
                                        i += 1
                        else:
                                sol_cons = {}

                        sol_lambda = {}

                        opt_problem.addSol(self.__class__.__name__, sol_name, objfunc, sol_time,
                                sol_evals, sol_inform, sol_vars, sol_objs, sol_cons, sol_options,
                                display_opts=disp_opts, Lambda=sol_lambda, myrank=myrank,
                                arguments=args, **kwargs)

                fstar = [0.]*l
                for i in range(l):
                        fstar[i] = nsga2.doubleArray_getitem(f,i)
                        i += 1

                xstar = [0.]*n
                for i in range(n):
                        xstar[i] = nsga2.doubleArray_getitem(x,i)

                inform = {}
                return fstar, xstar, {'fevals':nfeval,'time':sol_time,'inform':inform}


        def _on_setOption(self, name, value):
                '''
                Set Optimizer Option Value (Optimizer Specific Routine)

                Documentation last updated:  May. 16, 2008 - Ruben E. Perez
                '''
                pass


        def _on_getOption(self, name):
                '''
                Get Optimizer Option Value (Optimizer Specific Routine)

                Documentation last updated:  May. 17, 2008 - Ruben E. Perez
                '''

                pass


        def _on_getInform(self, infocode):
                '''
                Get Optimizer Result Information (Optimizer Specific Routine)

                Keyword arguments:
                -----------------
                id -> STRING: Option Name

                Documentation last updated:  May. 17, 2008 - Ruben E. Perez
                '''

                pass


        def _on_flushFiles(self):
                '''
                Flush the Output Files (Optimizer Specific Routine)

                Documentation last updated:  August. 09, 2009 - Ruben E. Perez
                '''

                pass


if __name__ == '__main__':
        # Test NSGA2
        print('Testing ...')
        nsga2 = NSGA2()
        print(nsga2)

