"""
hs - Python Version of the Augmented Lagrangian Harmony Search Optimizer

hso if a global optimizer which solves problems of the form:

			min F(x)

	subject to: Gi(x)  = 0, i = 1(1)ME
				Gj(x) <= 0, j = ME+1(1)M
				xLB <= x <= xUB

"""

__version__ = '$Revision: $'




import random, time #os, sys
#import pdb
from math import floor
import numpy

inf = 10.E+20  # define a value for infinity
eps = 1.0	# define a value for machine precision
while ((eps/2.0 + 1.0) > 1.0):
	eps = eps/2.0
eps = 2.0*eps


# alhso function
def HS(dimensions,constraints,neqcons,xtype,x0,xmin,xmax,
	memsize,maxoutiter,maxinniter,stopcriteria,stopiters,etol,
	itol,atol,rtol,prtoutiter,prtinniter,r0,hmcr,par,bw,
	fileout,filename,rseed,scale,objfunc):

	"""
	Python Version of the Augmented Lagrangian Harmony Search Optimizer

    Arguments:
        1-dimensions:
			[] number of optimization varialbes
        2-constraints:
			[] number of constraints
        3-neqcons:
			[] number of equality constraints
        4-xtype:
			[Array] array marking the continuous variables with 0, and
			other type with 1
        5-x0:
			[]
        6-xmin:
			[]
        7-xmax:
			[]
        8-size:

        9-maxoutiter:

        10-maxinniter:

        11-stopcriteria:

        12-stopiters:

        13-etol:

        14-itol:

        15-atol:
			[] min change in the objective function to stop
        16-rtol:
			[] min Relative Change in Objective to stop
        17-prtoutiter:
			[Integer] every prtoutiter the variables, objective function value
			will be printed, if prtoutiter = 0 nothing will be printed
        18-prtinniter:
			[Integer] print inner iteration to decide whether to print the variables,
			objective function value
        19-r0:
			[Float] Initial Penalty Factor
        20-hmcr:

        21-par:

        22-bw:

        23-fileout:

        24-filename:

        25-rseed:

        26-scale:

        27-objfunc:

	"""

	# Set random number seed
	rand = random.Random()
	if rseed == {}:
		rseed = time.time()

	rand.seed(rseed)


	if fileout == 1:
		if filename == '' :
			filename = 'Print.out'
		ofile = open(filename,'w')


	if scale == 1:
		dbw = (xmax - xmin)/bw
		# get the center of the space of each variable
		space_centre = numpy.zeros(dimensions,float)
		space_halflen = numpy.zeros(dimensions,float)
		for j in range(dimensions):
			space_centre[j] = (xmin[j] + xmax[j])/2.0
			space_halflen[j] = ((xmax[j] - xmin[j])/2.0)
		# make xmin -1 and xmax 2
		xmin = -numpy.ones(dimensions,float)
		xmax =  numpy.ones(dimensions,float)
		bw = (xmax - xmin)/dbw

	# Initialize Augmented Lagrange
	rp_val = numpy.ones(constraints, float)*r0

	lambda_val = numpy.zeros(constraints, float)
	lambda_old = numpy.zeros(constraints, float)

	# Initialize Harmony Memory
	HM = numpy.zeros((memsize,dimensions+1), float)
	discrete_i = []
	for i in range(memsize):
		for j in range(dimensions):
			HM[i,j] = xmin[j] + rand.random()*(xmax[j]-xmin[j])
			if xtype[j] == 1:
				discrete_i.append(j)
	# assign the initial variable values to all the Harmony memory columns
	if x0 != []:
		if scale == 1:
			HM[:,:-1] = (x0[:] - space_centre)/space_halflen
		else:
			HM[:,:-1] = x0[:]

	# Initialize Harmony Memory Augmented Lagrange
	x_val = numpy.zeros(dimensions, float)
	x_tmp = numpy.zeros(dimensions, float)
	tau_val = numpy.zeros(constraints, float)
	nfevals = 0
	#best_L_val = 0
	for i in range(memsize):

		# apply each set of variable values in the harmony memory on the
		# objective function
		if scale == 1:
			x_tmp = (HM[i,:-1] * space_halflen) + space_centre
		else:
			x_tmp = HM[i,:-1]

		# if the variable is discrete round it
		for m in discrete_i:
			x_tmp[m] = floor(x_tmp[m] + 0.5)

		# Evaluate Ojective Function
		[f_val,g_val] = objfunc(x_tmp)

		nfevals += 1

		# Augmented Lagrangian Value
		L_val = f_val

		if constraints > 0:
			# Equality Constraints
			for l in range(neqcons):
				tau_val[l] = g_val[l]

			# Inequality Constraints
			for l in range(neqcons,constraints):
				if rp_val[l] != 0:
					if g_val[l] > -lambda_val[l]/(2*rp_val[l]):
						tau_val[l] = g_val[l]
					else:
						tau_val[l] = -lambda_val[l]/(2*rp_val[l])
				else:
					tau_val[l] = g_val[l]

			for l in range(constraints):
				L_val += lambda_val[l]*tau_val[l] + rp_val[l]*tau_val[l]**2

		HM[i,dimensions] = L_val


	# Initialize Best
	best_x_val = numpy.zeros(dimensions, float)
	best_f_val = []
	best_g_val = numpy.zeros(constraints, float)

# 	best_x_old = numpy.zeros(dimensions, float)
	best_f_old = []
	best_g_old = numpy.zeros(constraints, float)


	# Outer Optimization Loop
	k_out = 0
	kobj = 0
	iobj = 0
	stop_main_flag = 0
	while ((k_out < maxoutiter) and (stop_main_flag == 0)):

		k_out += 1

		# Inner Optimization Loop
		k_inn = 0
		while k_inn < maxinniter:

			k_inn += 1

			# New Harmony Improvisation (randomly selected and pitched variable values)
			for j in range(dimensions):

				if ((rand.random() < hmcr) or (x0 != [] and k_out == 1)):

					# Harmony Memory Considering get a random values from the
					# Harmony memory then pitch adjusted with tha par value
					x_val[j] = HM[int(memsize*rand.random()),j]

					# Pitch Adjusting
					if rand.random() <= par:
						if rand.random() > 0.5:
							x_val[j] += rand.random()*bw[j]
						else:
							x_val[j] -= rand.random()*bw[j]

				else:

					# Random Searching
					x_val[j] = xmin[j] + rand.random()*(xmax[j]-xmin[j])


				# Check for improvisations out of range
				if x_val[j] > xmax[j]:
					x_val[j] = xmax[j]
				elif x_val[j] < xmin[j]:
					x_val[j] = xmin[j]


			# Evaluate the objective function with the pitched variables values x_val
			if scale == 1:
				x_tmp = (x_val * space_halflen) + space_centre
			else:
				x_tmp = x_val
			for m in discrete_i:
				x_tmp[m] = floor(x_tmp[m] + 0.5)
			[f_val,g_val] = objfunc(x_tmp)
			nfevals += 1

			# Lagrangian Value
			L_val = f_val
			if constraints > 0:

				# Equality Constraints
				for l in range(neqcons):
					tau_val[l] = g_val[l]

				# Inequality Constraints
				for l in range(neqcons,constraints):
					if (rp_val[l] != 0):
						if (g_val[l] > -lambda_val[l]/(2*rp_val[l])):
							tau_val[l] = g_val[l]
						else:
							tau_val[l] = -lambda_val[l]/(2*rp_val[l])
					else:
						tau_val[l] = g_val[l]

				#
				for l in range(constraints):
					L_val += lambda_val[l]*tau_val[l] + rp_val[l]*tau_val[l]**2



			feasible = True
			if constraints > 0:
				for l in range(constraints):
					if (l < neqcons):
						if abs(g_val[l]) > etol:
							feasible = False
							break
					else:
						if g_val[l] > itol:
							feasible = False
							break

			# first outer loop iteration or there is initial values for the variables
			if feasible or (k_out == 1 and x0 != []):

				# Harmony Memory Update

				# compare the values of the objective function
				# and get the worst one(max value)
				hmax_num = 0
				hmax = HM[0,dimensions] # value of the objective function of te first set of variable
				for i in range(memsize):
					if HM[i,dimensions] > hmax:
						hmax_num = i
						hmax = HM[i,dimensions]
				# if the obj_func value of the randomly selected pitched variables is
				# better than the worst
				if L_val < hmax: # replace these worst variables values with the pitched values
					for j in range(dimensions):
						HM[hmax_num,j] = x_val[j]
					HM[hmax_num,dimensions] = L_val

				# compare the values of the objective function
				# and get the best one(min value)
				hmin_num = 0
				hmin = HM[0,dimensions]
				for i in range(memsize):
					if HM[i,dimensions] < hmin:
						hmin_num = i
						hmin = HM[i,dimensions]
				# if the obj_func value of the randomly selected pitched variables equals to the best
				if L_val == hmin:

					best_x_val = x_val
					best_f_val = f_val
					best_g_val = g_val

					# Print Inner
					if prtinniter != 0:
						# output to screen
						print('%d Inner Iteration of %d Outer Iteration' %(k_inn,k_out))
						print(L_val)

						if (scale == 1):
							x_tmp = (x_val * space_halflen) + space_centre
						else:
							x_tmp = x_val
						for m in discrete_i:
							x_tmp[m] = floor(x_tmp[m] + 0.5)
						print(x_tmp)

						print(f_val)
						print(g_val)
						print(nfevals)

					if fileout == 1:
						# output to filename
						pass

					break



		if (best_f_val == [] and k_out == 1 and x0 == []):

			# Re-Initialize Harmony Memory
			HM = numpy.zeros((memsize,dimensions+1), float)
			for i in range(memsize):
				for j in range(dimensions):
					HM[i,j] = xmin[j] + rand.random()*(xmax[j]-xmin[j])

			# Re-Initialize Harmony Memory Augmented Lagrange
			for i in range(memsize):

				# Evaluate Ojective Function
				if (scale == 1):
					x_tmp = (HM[i,:-1] * space_halflen) + space_centre
				else:
					x_tmp = HM[i,:-1]
				for m in discrete_i:
					x_tmp[m] = floor(x_tmp[m] + 0.5)
				[f_val,g_val] = objfunc(x_tmp)
				nfevals += 1

				# Augmented Lagrangian Value
				L_val = f_val
				if (constraints > 0):

					# Equality Constraints
					for l in range(neqcons):
						tau_val[l] = g_val[l]

					# Inequality Constraints
					for l in range(neqcons,constraints):
						if (rp_val[l] != 0):
							if (g_val[l] > -lambda_val[l]/(2*rp_val[l])):
								tau_val[l] = g_val[l]
							else:
								tau_val[l] = -lambda_val[l]/(2*rp_val[l])
						else:
							tau_val[l] = g_val[l]

					#
					for l in range(constraints):
						L_val += lambda_val[l]*tau_val[l] + rp_val[l]*tau_val[l]**2


				#
				HM[i,dimensions] = L_val


			#
			k_out -= 1
			continue



		# Print Outer
		if (prtoutiter != 0 and numpy.mod(k_out,prtoutiter) == 0):

			# Output to screen
			print(("="*80 + "\n"))
			print(("NUMBER OF ITERATIONS: %d\n" %(k_out)))
			print(("NUMBER OF OBJECTIVE FUNCTION EVALUATIONS: %d\n" %(nfevals)))
			print("OBJECTIVE FUNCTION VALUE:")
			print(("\tF = %g\n" %(best_f_val)))
			if (constraints > 0):
				# Equality Constraints
				print("EQUALITY CONSTRAINTS VALUES:")
				for l in range(neqcons):
					print(("\tG(%d) = %g" %(l,best_g_val[l])))
				# Inequality Constraints
				print("\nINEQUALITY CONSTRAINTS VALUES:")
				for l in range(neqcons,constraints):
					print(("\tH(%d) = %g" %(l,best_g_val[l])))
			print("\nLAGRANGIAN MULTIPLIERS VALUES:")
			for l in range(constraints):
				print(("\tL(%d) = %g" %(l,lambda_val[l])))

			print("\nDESIGN VARIABLES VALUES:")
			if (scale == 1):
				x_tmp = (best_x_val[:] * space_halflen) + space_centre
			else:
				x_tmp = best_x_val[:]

			for m in discrete_i:
				x_tmp[m] = floor(x_tmp[m]+0.5)
			text = ''

			for j in range(dimensions):
				text += ("\tP(%d) = %9.3e\t" %(j,x_tmp[j]))
				if (numpy.mod(j+1,3) == 0):
					text +=("\n")
			print(text)
			print(("="*80 + "\n"))


		if (fileout == 1):
			# Output to filename
			ofile.write("\n" + "="*80 + "\n")
			ofile.write("\nNUMBER OF ITERATIONS: %d\n" %(k_out))
			ofile.write("\nNUMBER OF OBJECTIVE FUNCTION EVALUATIONS: %d\n" %(nfevals))
			ofile.write("\nOBJECTIVE FUNCTION VALUE:\n")
			ofile.write("\tF = %g\n" %(best_f_val))
			if (constraints > 0):
				# Equality Constraints
				ofile.write("\nEQUALITY CONSTRAINTS VALUES:\n")
				for l in range(neqcons):
					ofile.write("\tG(%d) = %g\n" %(l,best_g_val[l]))
				# Inequality Constraints
				ofile.write("\nINEQUALITY CONSTRAINTS VALUES:\n")
				for l in range(neqcons,constraints):
					ofile.write("\tH(%d) = %g\n" %(l,best_g_val[l]))

			ofile.write("\nLAGRANGIAN MULTIPLIERS VALUES:\n")
			for l in range(constraints):
				ofile.write("\tL(%d) = %g\n" %(l,lambda_val[l]))

			ofile.write("\nDESIGN VARIABLES VALUES:\n")

			if (scale == 1):
				x_tmp = (best_x_val[:] * space_halflen) + space_centre
			else:
				x_tmp = best_x_val[:]

			for m in discrete_i:
				x_tmp[m] = floor(x_tmp[m]+0.5)
			text = ''

			for j in range(dimensions):
				text += ("\tP(%d) = %9.3e\t" %(j,x_tmp[j]))
				if (numpy.mod(j+1,3) == 0):
					text +=("\n")

			ofile.write(text)
			ofile.write("\n" + "="*80 + "\n")
			ofile.flush()


		# Test Constraint convergence
		stop_constraints_flag = 0
		if constraints == 0:
			stop_constraints_flag = 1
		else:
			for l in range(neqcons):
				if (abs(best_g_val[l]) <= etol):
					stop_constraints_flag += 1
			for l in range(neqcons,constraints):
				if (best_g_val[l] <= itol):
					stop_constraints_flag += 1
			if (stop_constraints_flag == constraints):
				stop_constraints_flag = 1
			else:
				stop_constraints_flag = 0

		# Test Position and Function convergence
		if best_f_old == []:
			best_f_old = best_f_val
		stop_criteria_flag = 0

		if stopcriteria == 1:

			# Absolute Change in Objective
			absfdiff = abs(best_f_val - best_f_old)
			if absfdiff <= atol:
				kobj += 1
			else:
				kobj = 0

			# Relative Change in Objective
			if abs(best_f_old) > 1e-10:
				if abs(absfdiff/abs(best_f_old)) <= rtol:
					iobj += 1
				else:
					iobj = 0

			#
			best_f_old = best_f_val

			#
			if (kobj > stopiters or iobj > stopiters):
				stop_criteria_flag = 1
			else:
				stop_criteria_flag = 0


		# Test Convergence
		if stop_constraints_flag == 1 and stop_criteria_flag == 1:
			stop_main_flag = 1
		else:
			stop_main_flag = 0


		# Update Augmented Lagrangian Terms
		if stop_main_flag == 0:

			if constraints > 0:

				# Tau for Best
				for l in range(neqcons):
					tau_val[l] = best_g_val[l]
				for l in range(neqcons,constraints):
					if (best_g_val[l] > -lambda_val[l]/(2*rp_val[l])):
						tau_val[l] = best_g_val[l]
					else:
						tau_val[l] = -lambda_val[l]/(2*rp_val[l])

				# Update Lagrange Multiplier
				for l in range(constraints):
					lambda_old[l] = lambda_val[l]
					lambda_val[l] += 2*rp_val[l]*tau_val[l]

				# Update Penalty Factor
				for l in range(neqcons):
					if (abs(best_g_val[l]) > abs(best_g_old[l]) and abs(best_g_val[l]) > etol):
						rp_val[l] = 2.0*rp_val[l]
					elif (abs(best_g_val[l]) <= etol):
						rp_val[l] = 0.5*rp_val[l]
				for l in range(neqcons,constraints):
					if (best_g_val[l] > best_g_old[l] and best_g_val[l] > itol):
						rp_val[l] = 2.0*rp_val[l]
					elif (best_g_val[l] <= itol):
						rp_val[l] = 0.5*rp_val[l]

				# Apply Lower Bounds on rp
				for l in range(neqcons):
					if (rp_val[l] < 0.5*(abs(lambda_val[l])/etol)**0.5):
						rp_val[l] = 0.5*(abs(lambda_val[l])/etol)**0.5
				for l in range(neqcons,constraints):
					if (rp_val[l] < 0.5*(abs(lambda_val[l])/itol)**0.5):
						rp_val[l] = 0.5*(abs(lambda_val[l])/itol)**0.5
				for l in range(constraints):
					if (rp_val[l] < 1):
						rp_val[l] = 1

				#
				best_g_old[:] = best_g_val[:]





	# Print Results
	if (prtoutiter != 0):

		# Output to screen
		print(("="*80 + "\n"))
		print(("RANDOM SEED VALUE: %.8f\n" %(rseed)))
		print(("NUMBER OF ITERATIONS: %d\n" %(k_out)))
		print(("NUMBER OF OBJECTIVE FUNCTION EVALUATIONS: %d\n" %(nfevals)))
		print("OBJECTIVE FUNCTION VALUE:")
		print(("\tF = %g\n" %(best_f_val)))
		if (constraints > 0):
			# Equality Constraints
			print("EQUALITY CONSTRAINTS VALUES:")
			for l in range(neqcons):
				print(("\tG(%d) = %g" %(l,best_g_val[l])))
			# Inequality Constraints
			print("\nINEQUALITY CONSTRAINTS VALUES:")
			for l in range(neqcons,constraints):
				print(("\tH(%d) = %g" %(l,best_g_val[l])))
		print("\nLAGRANGIAN MULTIPLIERS VALUES:")
		for l in range(constraints):
			print(("\tL(%d) = %g" %(l,float(lambda_val[l]))))

		print("\nDESIGN VARIABLES VALUES:")
		if (scale == 1):
			x_tmp = (best_x_val[:] * space_halflen) + space_centre
		else:
			x_tmp = best_x_val[:]
		for m in discrete_i:
			x_tmp[m] = floor(x_tmp[m]+0.5)
		text = ''
		for j in range(dimensions):
			text += ("\tP(%d) = %9.3e\t" %(j,x_tmp[j]))
			if (numpy.mod(j+1,3) == 0):
				text +=("\n")
		print(text)
		print(("="*80 + "\n"))

	if (fileout == 1):
		# Output to filename
		ofile.write("\n" + "="*80 + "\n")
		ofile.write("RANDOM SEED VALUE: %.8f\n" %(rseed))
		ofile.write("\nNUMBER OF ITERATIONS: %d\n" %(k_out))
		ofile.write("\nNUMBER OF OBJECTIVE FUNCTION EVALUATIONS: %d\n" %(nfevals))
		ofile.write("\nOBJECTIVE FUNCTION VALUE:\n")
		ofile.write("\tF = %g\n" %(best_f_val))
		if (constraints > 0):
			# Equality Constraints
			ofile.write("\nEQUALITY CONSTRAINTS VALUES:\n")
			for l in range(neqcons):
				ofile.write("\tG(%d) = %g\n" %(l,best_g_val[l]))
			# Inequality Constraints
			ofile.write("\nINEQUALITY CONSTRAINTS VALUES:\n")
			for l in range(neqcons,constraints):
				ofile.write("\tH(%d) = %g\n" %(l,best_g_val[l]))
		ofile.write("\nLAGRANGIAN MULTIPLIERS VALUES:\n")
		for l in range(constraints):
			ofile.write("\tL(%d) = %g\n" %(l,float(lambda_val[l])))

		ofile.write("\nDESIGN VARIABLES VALUES:\n")
		if (scale == 1):
			x_tmp = (best_x_val[:] * space_halflen) + space_centre
		else:
			x_tmp = best_x_val[:]
		for m in discrete_i:
			x_tmp[m] = floor(x_tmp[m]+0.5)
		text = ''
		for j in range(dimensions):
			text += ("\tP(%d) = %9.3e\t" %(j,x_tmp[j]))
			if (numpy.mod(j+1,3) == 0):
				text +=("\n")
		ofile.write(text)
		ofile.write("\n" + "="*80 + "\n")

		ofile.close()


	# Results
	if (scale == 1):
		opt_x = (best_x_val * space_halflen) + space_centre
	else:
		opt_x = best_x_val
	for m in discrete_i:
		opt_x[m] = int(floor(opt_x[m] + 0.5))
	opt_f = best_f_val
	opt_g = best_g_val
	opt_lambda = lambda_val[:]

	return opt_x,opt_f,opt_g,opt_lambda,nfevals,'%.8f' %(rseed)



def Chso(ND,nc,nec,xtype,x0,lb,ub,bw,HMS,HMCR,PAR,maxIter,printout,rseed,objfunc):
	"""
	CHSO function - Python Version of the Constrained Harmony Search Optimizer
	"""

	# Set random number seed
	rand = random.Random()
	if rseed == {}:
		rseed = time.time()


	# Initialize
	HM = numpy.zeros((HMS,ND+1), float)
	for i in range(HMS):
		for j in range(ND):
			HM[i,j] = lb[j] + rand.random()*(ub[j] - lb[j])
		[f0,gs0] = objfunc(HM[i,:-1])
		HM[i,ND] = f0

	# Print Initial Header
	if (printout == 1):
		#print(' Iteration   Func-count     min f(x)')
		print(' Iteration   min f(x)');


	# Iterations Loop
	x = numpy.zeros(ND,float)
	numFunEvals = 0
	k = 0
	status = 0
	while status != 1:

		# New Harmony Improvisation
		for j in range(ND):

			#
			if (rand.random() >= HMCR):

				# Random Searching
				x[j] = lb[j] + rand.random()*(ub[j] - lb[j])

			else:

				# Harmony Memory Considering
				x[j] = HM[int(HMS*rand.random()),j]

				# Pitch Adjusting
				if (rand.random() <= PAR):
					if (rand.random() > 0.5):
						x[j] = x[j] + rand.random()*((ub[j] - lb[j])/bw[j])
					else:
						x[j] = x[j] - rand.random()*((ub[j] - lb[j])/bw[j])


		#
		[fval,gvals] = objfunc(x)
		numFunEvals += 1

		#
		if (sum(gvals) <= 0):

			# Harmony Memory Update
			hmax_num = 0
			hmax = HM[0,ND]
			for i in range(HMS):
				if (HM[i,ND] > hmax):
					hmax_num = i
					hmax = HM[i,ND]

			if (fval < hmax):
				for j in range(ND):
					HM[hmax_num,j] = x[j]
				HM[hmax_num,ND] = fval

			hmin_num = 0
			hmin = HM[0,ND]
			for i in range(HMS):
				if (HM[i,ND] < hmin):
					hmin_num = i
					hmin = HM[i,ND]

			# Print
			if (fval == hmin):
				opt_x = x
				opt_f = fval
				opt_g = gvals
				if (printout == 1):
					print(('%i,%f' %(k,fval)))


		# Test Convergence
		if k == maxIter-1:
			if (printout == 1):
				print('\nMaximum number of iterations exceeded\n')
				print('increase OPTIONS.MaxIter\n')
			status = 1
		else:
			k += 1


	# Print
	if (printout == 1):
		print('\nNumber of function evaluations = %f\n' %(numFunEvals))

	return opt_x,opt_f,opt_g,numFunEvals,'%.8f' %(rseed)


# Optimizers Test
if __name__ == '__main__':

	print('Testing ...')

	# Test alpso
	HS = HS()
	print(HS)

