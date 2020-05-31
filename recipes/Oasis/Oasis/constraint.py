"""
Constraint

Holds the Python Design Optimization Classes (base and inherited).

"""

__version__ = '$Revision: $'

#import os, sys
#import pdb



inf = 10.E+20  # define a value for infinity


class Constraint(object):

	"""
	Optimization Constraint Class
	"""

	def __init__(self, name, type='i', *args, **kwargs):

		"""
		Constraint Class Initialization

		arguments:
			- name :
				[String]: Variable Name
			- type :
				[String] Variable Type ('i'-inequality, 'e'-equality), Default = 'i'
				inequality constrain like x1+x3 = 10, equality constrain like x1*x3 > 0
				Equality Constraints should be defined BEFORE Inequality Constraints
			- lower :
				[Integer] Variable Lower Value
			- upper :
				[Integer] Variable Upper Value
			- choices :
				[Dictionary] Variable Choices
	"""
		self.name = name
		self.type = type[0].lower()
		self.value = 0.0

		if (type[0].lower() == 'i'):
			self.upper = 0.0
			self.lower = -float(inf)

			for key in kwargs.keys():
				if key == 'lower':
					self.lower = float(kwargs['lower'])
				if key == 'upper':
					self.upper = float(kwargs['upper'])
		elif (type[0].lower() == 'e'):
			if 'equal' in kwargs:
				self.equal = float(kwargs['equal'])
			else:
				self.equal = 0.0
		else:
			raise IOError('Constraint type not understood -- use either i(nequality) or e(quality)')



	def ListAttributes(self):

		"""
		Print Structured Attributes List
		"""

		ListAttributes(self)


	def __str__(self):

		"""
		Print Constraint
		"""

		if (self.type == 'e'):
			return ( '	    Name        Type'+' '*25+'Bound\n'+'	 '+str(self.name).center(9) +'    e %23f = %5.2e\n' %(self.value,self.equal))
		if (self.type == 'i'):
			return ( '	    Name        Type'+' '*25+'Bound\n'+'	 '+str(self.name).center(9) +'	  i %15.2e <= %8f <= %8.2e\n' %(self.lower,self.value,self.upper))



def ListAttributes(self):

	"""
	Print Structured Attributes List
	"""

	print('\n')
	print('Attributes List of: ' + repr(self.__dict__['name']) + ' - ' + self.__class__.__name__ + ' Instance\n')
	self_keys = self.__dict__.keys()
	self_keys.sort()
	for key in self_keys:
		if key != 'name':
			print(str(key) + ' : ' + repr(self.__dict__[key]))
	print('\n')




# Constraint Test
if __name__ == '__main__':

	print('Testing ...')

	# Test Constraint
	con = Constraint('g')
	con.ListAttributes()

