"""
ALHSO - A Python interface to ALHSO.
"""

__version__ = '$Revision: $'

# try:
# 	from . import hs
# except:
# 	raise ImportError('HS shared library failed to import')


import os #, sys
import copy, time
import numpy
from Oasis.optimizer import Optimizer
from Oasis.hs import HS, Chso


inf = 10.E+20  # define a value for infinity
eps = 1.0	# define a value for machine precision
while ((eps/2.0 + 1.0) > 1.0):
	eps = eps/2.0
eps = 2.0*eps



class ALHSO(Optimizer):
	"""
	ALHSO Optimizer Class - Inherited from Optimizer Abstract Class
    attributes of ALHSO class will overwrite attributes of optimizer class
	"""

	def __init__(self, pll_type=None, *args, **kwargs):
		"""
		ALHSO Optimizer Class Initialization

		arguments:

		- pll_type :
            [String]: Parallel Implementation (None, 'POA'-Parallel Objective
            Analysis), *Default* = None
        - def_opts:
            [Dictionary] with the following keys
            - hms:
                Memory Size [1,50]
            - hmcr:
                Probability rate of choosing from memory [0.7,0.99]
            - par:
                Pitch adjustment rate [0.1,0.99]
            - dbw:
                Variable Bandwidth Quantization
            - maxoutiter:
                Maximum Number of Outer Loop Iterations (Major Iterations)
            - maxinniter:
                Maximum Number of Inner Loop Iterations (Minor Iterations)
            - stopcriteria:
                Stopping Criteria Flag
            - stopiters:
                Consecutively Number of Outer Iterations for which the Stopping
                Criteria must be Satisfied
            - etol:
                Absolute Tolerance for Equality constraints
            - itol:
                Absolute Tolerance for Inequality constraints
            - atol:
                Absolute Tolerance for Objective Function
            - rtol:
                Relative Tolerance for Objective Function
            - prtoutiter:
                Number of Iterations Before Print Outer Loop Information
            - prtinniter:
                Number of Iterations Before Print Inner Loop Information
            - xinit:
                Initial Position Flag (0 - no position, 1 - position given)
				Initial values for the variables
            - rinit:
                Initial Penalty Factor
            - fileout:
                Flag to Turn On Output to filename
            - filename:
                We could probably remove fileout flag if filename or fileinstance
                is given
            - seed:
                Random Number Seed (0 - Auto-Seed based on time clock)
            - scaling:
                Design Variables Scaling Flag (0 - no scaling, 1 - scaling between [-1,1])
		"""
		# initialize first the ALHSO object the intialize the Optimizer object

		if (pll_type == None):
			self.poa = False
		elif (pll_type.upper() == 'POA'):
			self.poa = True
		else:
			raise ValueError("pll_type must be either None or 'POA'")

		name = 'ALHSO'
		category = 'Global Optimizer'
		def_opts = {'hms':[int,5], 'hmcr':[float,0.95],
					'par':[float,0.65],'dbw':[int,2000],
					'maxoutiter':[int,2e3],'maxinniter':[int,2e2],
					'stopcriteria':[int,1],'stopiters':[int,10],
					'etol':[float,1e-6],'itol':[float,1e-6],
					'atol':[float,1e-6],'rtol':[float,1e-6],
					'prtoutiter':[int,0],'prtinniter':[int,0],
					'xinit':[int,0],'rinit':[float,1.0],
					'fileout':[int,1],'filename':[str,'ALHSO.out'],
					'seed':[float,0],'scaling':[int,1],
					}

		informs = {}

		# initialize the super class optimizer with the default attribute values
		# from the ALHSO sub class
		Optimizer.__init__(self, name, category, def_opts, informs, *args, **kwargs)


	def __solve__(self, opt_problem={}, store_sol=True, disp_opts=False,
				store_hst=False, hot_start=False, *args, **kwargs):
		"""
		Run Optimizer (Optimize Routine)

		arguments:

		- opt_problem :
			[Instance] Optimization instance
		- store_sol :
			[Boolen] Store solution in Optimization class flag, Default = True
		- disp_opts :
			[Boolen] Flag to display options in solution text, Default = False
		- store_hst :
			[Boolen/String] Flag/filename to store optimization history, Default = False
		- hot_start :
			[Boolen/String] Flag/filename to read optimization history, Default = False
		- display_opts:
			[Boolen] keyword argument to decide to plot the result of the
			optimization

		- Additional arguments and keyword arguments are passed to the
			objective function call.
		"""
		if 'display_opts' in kwargs:
			sol_dispOpt = kwargs['display_opts']
			del kwargs['display_opts']
		else:
			sol_dispOpt = False


		# parallel processing
		if self.poa:
			try:
				import mpi4py
				from mpi4py import MPI
			except ImportError:
				print('pyALHSO: Parallel objective Function Analysis requires mpi4py')
			comm = MPI.COMM_WORLD
			nproc = comm.Get_size()
			if mpi4py.__version__[0] == '0':
				Bcast = comm.Bcast
			elif mpi4py.__version__[0] == '1':
				Bcast = comm.bcast
			elif mpi4py.__version__[0] == '3':
				Bcast = comm.bcast
			self.pll = True
			self.myrank = comm.Get_rank()
		else:
			self.pll = False
			self.myrank = 0

		myrank = self.myrank

		# store history
		def_fname = self.options['filename'][1].split('.')[0]
		hos_file, log_file, tmp_file = self._setHistory(opt_problem.name, store_hst, hot_start, def_fname)



		# ALHSO - Objective/Constraint Values Function
		def objconfunc(x, *args, **kwargs):

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
			else:
				[ff,gg,fail] = opt_problem.obj_fun(xn, *args, **kwargs)

			# Store History
			if (myrank == 0):
				if self.sto_hst:
					log_file.write(x,'x')
					log_file.write(ff,'obj')
					log_file.write(gg,'con')
					log_file.write(fail,'fail')

			# Assigenment
			g = numpy.zeros(len(opt_problem.constraints.keys()),float)
			if (fail == 1):
				# Objective Assigment
				f = inf
				# Constraints Assigment
				for i in range(len(opt_problem.constraints.keys())):
					g[i] = inf
			else:
				# Objective Assigment
				if isinstance(ff,complex):
					f = ff.astype(float)
				else:
					f = ff
				# Constraints Assigment
				for i in range(len(opt_problem.constraints.keys())):
					if isinstance(gg[i],complex):
						g[i] = gg[i].astype(float)
					else:
						g[i] = gg[i]

			return f,g



		# Variables Handling
		n = len(opt_problem.variables.keys())
		# lower bound
		xl = numpy.zeros(n,float)
		# upper bound
		xu = numpy.zeros(n,float)
		type = numpy.zeros(n,int)
		i = 0
		for key in opt_problem.variables.keys():
			xl[i] = opt_problem.variables[key].lower
			xu[i] = opt_problem.variables[key].upper
			# type of optimization variable
			if opt_problem.variables[key].type == 'c':
				type[i] = 0
			else:
				type[i] = 1
			i += 1

		# Variables Groups Handling
		if opt_problem.use_groups:
			group_ids = {}
			k = 0
			for key in opt_problem.vargroups.keys():
				group_len = len(opt_problem.vargroups[key]['ids'])
				group_ids[opt_problem.vargroups[key]['name']] = [k,k+group_len]
				k += group_len

		# Constraints Handling
		m = len(opt_problem.constraints.keys())
		me = 0
		#i = 0
		if m > 0:
			for key in opt_problem.constraints.keys():
				if opt_problem.constraints[key].type == 'e':
					me += 1
			#i += 1

		# Objective Handling
		objfunc = opt_problem.obj_fun
		nobj = len(opt_problem.objectives.keys())


		# Setup argument list values
		hms = self.options['hms'][1]
		imax = self.options['maxoutiter'][1]
		cmax = self.options['maxinniter'][1]
		if (self.options['stopcriteria'][1]>=0 and self.options['stopcriteria'][1]<=1):
			stop = self.options['stopcriteria'][1]
		else:
			raise IOError('Incorrect Stopping Criteria Setting')
		nstop = self.options['stopiters'][1]
		etol = self.options['etol'][1]
		itol = self.options['itol'][1]
		atol = self.options['atol'][1]
		rtol = self.options['rtol'][1]
		if (myrank == 0):
			oout = self.options['prtoutiter'][1]
			iout = self.options['prtinniter'][1]
		else:
			oout = 0
			iout = 0
		xinit = self.options['xinit'][1]
		rinit = self.options['rinit'][1]
		hmcr = self.options['hmcr'][1]
		par = self.options['par'][1]
		dbw = self.options['dbw'][1]
		bw = (xu-xl)/dbw

		if myrank == 0:
			if (self.options['fileout'][1]>=0 and self.options['fileout'][1]<=2):
				fileout = self.options['fileout'][1]
			else:
				raise IOError('Incorrect fileout Setting')
		else:
			fileout = 0

		filename = self.options['filename'][1]

		if fileout == 1:
			if os.path.isfile(filename):
				os.remove(filename)
		seed = self.options['seed'][1]

		if myrank == 0:
			if seed == 0 and not self.hot_start:
				seed = time.time()
			if self.hot_start:
				seed = hos_file.read(-1,ident=['seed'])[0]['seed'][0][0]

		if self.pll:
			seed = Bcast(seed, root=0)
		if self.sto_hst and (myrank == 0):
			log_file.write(seed,'seed')

		scale = self.options['scaling'][1]

		xs = []
		if xinit == 1:
			for key in opt_problem.variables.keys():
				xs.append(opt_problem.variables[key].value)
			xs = numpy.array(xs)


		# Run ALHSO
		t0 = time.time()

		opt_x,opt_f,opt_g,opt_lambda,nfevals,rseed = HS(n,m,me,
			type,xs,xl,xu,hms,imax,cmax,stop,nstop,etol,itol,atol,rtol,oout,
			iout,rinit,hmcr,par,bw,fileout,filename,seed,scale,objconfunc)


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

			sol_name = 'ALHSO Solution to ' + opt_problem.name

			sol_options = copy.copy(self.options)
			if 'defaults' in sol_options:
				del sol_options['defaults']

			sol_inform = {}

			sol_evals = nfevals

			sol_vars = copy.deepcopy(opt_problem.variables)
			i = 0
			for key in sol_vars.keys():
				sol_vars[key].value = opt_x[i]
				i += 1

			sol_objs = copy.deepcopy(opt_problem.objectives)
			i = 0
			for key in sol_objs.keys():
				sol_objs[key].value = opt_f	# Note: takes only one!
				i += 1

			if m > 0:
				sol_cons = copy.deepcopy(opt_problem.constraints)
				i = 0
				for key in sol_cons.keys():
					sol_cons[key].value = opt_g[i]
					i += 1
			else:
				sol_cons = {}

			if m > 0:
				sol_lambda = numpy.zeros(m ,float)
				for i in range(m):
					sol_lambda[i] = opt_lambda[i]
			else:
				sol_lambda = {}


			opt_problem.addSol(self.__class__.__name__, sol_name, objfunc, sol_time,
				sol_evals, sol_inform, sol_vars, sol_objs, sol_cons, sol_options,
				display_opts=disp_opts, Lambda=sol_lambda, Seed=rseed,
				myrank=myrank, arguments=args, **kwargs)


		return opt_f, opt_x, {'opt_g':opt_g,'fevals':sol_evals,'time':sol_time}


	def _on_setOption(self, name, value):
		"""
		Set Optimizer Option Value (Optimizer Specific Routine)
		"""
		pass


	def _on_getOption(self, name):
		"""
		Get Optimizer Option Value (Optimizer Specific Routine)
		"""
		pass


	def _on_getInform(self, infocode):
		"""
		Get Optimizer Result Information (Optimizer Specific Routine)

		Keyword arguments:
		-----------------
		id -> STRING: Option Name
		"""
		pass


	def _on_flushFiles(self):
		"""
		Flush the Output Files (Optimizer Specific Routine)
		"""

		pass



# HSO Optimizer Class
class HSO(Optimizer):
	"""
	HSO Optimizer Class - Inherited from Optimizer Abstract Class
	"""

	def __init__(self, *args, **kwargs):
		"""
		HSO Optimizer Class Initialization
		"""
		name = 'HSO'
		category = 'Global Optimizer'
		def_opts = {
		'hms':[int,10],				# Memory Size [4,10]
		'dbw':[float,0.01],			#
		'hmcr':[float,0.96],		#
		'par':[float,0.6],			#
		'maxiter':[int,1e4],		# Maximum Number Iterations
		'printout':[int,0],			# Flag to Turn On Information Output
		'xinit':[int,0],			# Initial Position Flag (0 - no position, 1 - position given)
		'seed':[float,0],			# Random Number Seed (0 - Auto-Seed based on time clock)
		}
		informs = {}
		Optimizer.__init__(self, name, category, def_opts, informs, *args, **kwargs)


	def __solve__(self, opt_problem={}, store_sol=True, disp_opts=False, *args, **kwargs):
		"""
		Run Optimizer (Optimize Routine)
		"""

		if 'display_opts' in kwargs:
			sol_dispOpt = kwargs['display_opts']
			del kwargs['display_opts']
		else:
			sol_dispOpt = False


		# HSO - Objective/Constraint Values Function
		def objconfunc(x, *args, **kwargs):

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
			[ff,gg,fail] = opt_problem.obj_fun(xn, *args, **kwargs)

			#
			g = numpy.zeros(len(opt_problem.constraints.keys()),float)
			if (fail == 1):
				# Objective Assigment
				f = inf
				# Constraints Assigment
				for i in range(len(opt_problem.constraints.keys())):
					g[i] = inf
			else:
				# Objective Assigment
				if isinstance(ff,complex):
					f = ff.astype(float)
				else:
					f = ff
				# Constraints Assigment
				for i in range(len(opt_problem.constraints.keys())):
					if isinstance(gg[i],complex):
						g[i] = gg[i].astype(float)
					else:
						g[i] = gg[i]

			return f,g



		# Variables Handling
		n = len(opt_problem.variables.keys())
		xl = numpy.zeros(n,float)
		xu = numpy.zeros(n,float)
		type = numpy.zeros(n,int)
		i = 0
		for key in opt_problem.variables.keys():
			xl[i] = opt_problem.variables[key].lower
			xu[i] = opt_problem.variables[key].upper
			if opt_problem.variables[key].type == 'c':
				type[i] = 0
			else:
				type[i] = 1
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
		m = len(opt_problem.constraints.keys())
		me = 0
		#i = 0
		if m > 0:
			for key in opt_problem.constraints.keys():
				if opt_problem.constraints[key].type == 'e':
					me += 1
			#i += 1

		# Objective Handling
		objfunc = opt_problem.obj_fun
		nobj = len(opt_problem.objectives.keys())


		# Setup argument list values
		hms = self.options['hms'][1]
		dbw = self.options['dbw'][1]
		bw = (xu-xl)/dbw
		hmcr = self.options['hmcr'][1]
		par = self.options['par'][1]
		maxiter = self.options['maxiter'][1]
		if (self.options['printout'][1]>=0 or self.options['printout'][1]<=1):
			printout = self.options['printout'][1]
		else:
			raise IOError('Incorrect printout Setting')
		seed = self.options['seed'][1]
		if seed == 0:
			seed = time.time()
		xinit = self.options['xinit'][1]
		xs = []
		if (xinit == 1):
			for key in opt_problem.variables.keys():
				xs.append(opt_problem.variables[key].value)
			xs = numpy.array(xs)


		# Run HSO
		t0 = time.time()
		opt_x,opt_f,opt_g,nfevals,rseed = Chso(n,m,me,type,xs,xl,xu,bw,hms,hmcr,par,maxiter,printout,seed,objconfunc)
		sol_time = time.time() - t0


		# Store Results
		if store_sol:

			sol_name = 'HSO Solution to ' + opt_problem.name

			sol_options = copy.copy(self.options)
			if 'defaults' in sol_options:
				del sol_options['defaults']

			sol_inform = {}

			sol_evals = nfevals

			sol_vars = copy.deepcopy(opt_problem.variables)
			i = 0
			for key in sol_vars.keys():
				sol_vars[key].value = opt_x[i]
				i += 1

			sol_objs = copy.deepcopy(opt_problem.objectives)
			i = 0
			for key in sol_objs.keys():
				sol_objs[key].value = opt_f	# Note: takes only one!
				i += 1

			if m > 0:
				sol_cons = copy.deepcopy(opt_problem.constraints)
				i = 0
				for key in sol_cons.keys():
					sol_cons[key].value = opt_g[i]
					i += 1
			else:
				sol_cons = {}

			sol_lambda = {}


			opt_problem.addSol(self.__class__.__name__, sol_name, objfunc, sol_time,
				sol_evals, sol_inform, sol_vars, sol_objs, sol_cons, sol_options,
				display_opts=disp_opts, Lambda=sol_lambda, Seed=rseed,
				arguments=args, **kwargs)


		return opt_f, opt_x, {}


	def _on_setOption(self, name, value):
		"""
		Set Optimizer Option Value (Optimizer Specific Routine)
		"""
		pass


	def _on_getOption(self, name):
		"""
		Get Optimizer Option Value (Optimizer Specific Routine)
		"""
		pass


	def _on_getInform(self, infocode):
		"""
		Get Optimizer Result Information (Optimizer Specific Routine)

		Keyword arguments:
		-----------------
		id -> STRING: Option Name
		"""
		pass


	def _on_flushFiles(self):
		"""
		Flush the Output Files (Optimizer Specific Routine)
		"""
		pass



# ALHSO Optimizer Test
if __name__ == '__main__':

	# Test ALHSO
	print('Testing ...')
	ALHSO = ALHSO()
	print(ALHSO)