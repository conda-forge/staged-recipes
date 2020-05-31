"""
Parameter

Holds the Python Design Optimization Classes (base and inherited).

"""

__version__ = '$Revision: $'



#import os, sys
#import pdb


inf = 10.E+20  # define a value for infinity



class Parameter(object):
	
	"""
	Optimization Parameter Class
	"""
	
	def __init__(self, name, value=0.0, *args, **kwargs):
		
		"""
		Parameter Class Initialization
		
		**Arguments:**
		
		- name -> STR: Parameter Name
		
		**Keyword arguments:**
		
		- value -> SCALAR: Parameter Value, *Default* = 0.0
		"""
		
		self.name = name
		self.value = value
		
		
	def ListAttributes(self):
		
		"""
		Print Structured Attributes List
		"""
		
		ListAttributes(self)
		
		
	def __str__(self):
		
		"""
		Print Structured List of Parameter
		"""
		
		return ('Name    Value\n'+'	 '+str(self.name).center(9) +'%14f\n' %(self.value))
	


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
	


if __name__ == '__main__':
	
	print('Testing ...')
	
	# Test Parameter
	par = Parameter('x')
	par.ListAttributes()
	
