"""
history

Holds the Python Design Optimization History Class.

"""

__version__ = '$Revision: $'



import os #, sys
import array as ARRAY
import numpy
#import pdb
#import shelve


class History(object):
	
	"""
	Abstract Class for Optimizer History Object
	"""
	
	def __init__(self, filename, mode, optimizer=None, opt_prob=None, *args, **kwargs):
		
		"""
		Optimizer History Class Initialization
		
		Arguments:
		
    		- filename :
                [String] Name for .bin and .cue file
    		- mode :
                [String] Either read ('r') or write ('w') mode
                
    		Keyword arguments:
    		- optimizer :
                [Instance] Opimizer class instance,  *Default* = None
    		- opt_prob :
                [String] Optimization Problem Name, *Default* = None
		"""
		
		self.filename = filename
		self.mode = mode
		
		bin_name = filename + '.bin'
		cue_name = filename + '.cue'
		
		

		if self.mode == 'w':
		
			if os.path.isfile(bin_name):
				os.remove(bin_name)
			if os.path.isfile(cue_name):
				os.remove(cue_name)
			
		else:
			
			if not os.path.isfile(bin_name):
				raise NameError('Error: filename %s.bin does not exist'%(filename))
			if not os.path.isfile(cue_name):
				raise NameError('Error: filename %s.cue does not exist'%(filename))

			
		
		self.bin_file = open(bin_name,mode+'b')
		self.cue_file = open(cue_name,mode)
		
		if self.mode == 'w':
			
			if optimizer == None:
				optname = 'None'
			else:
				optname = optimizer.name
			header = 'History for %s solving %s\n' %(optname,opt_prob)
			self.cue_file.write(header)

			
		elif self.mode == 'r':
			
			#
			self.cues = {}
			self.icount = {}

			lines = self.cue_file.readlines()			
			for line in lines[1:]:
				
				if len(line) < 3:
					break
				else:
					#read in positions
					tline = line.split()
					if tline[2] in self.cues:
						self.cues[tline[2]].append([int(tline[0]),int(tline[1])])
					else:
						self.cues[tline[2]] = [[int(tline[0]),int(tline[1])]]
						self.icount[tline[2]] = 0						
			self.cue_file.close()
		
		self.s_count = 0
		
		
	def close(self):
		
		"""
		Close Optimizer History Files
		"""
		
		self.bin_file.close()
		if self.mode == 'w':
			self.cue_file.close()
		
		
	def read(self, index=[], ident=['obj']):
		
		"""
		Read Data from Optimizer History Files
		
		Keyword arguments:
		
		- index -> LIST,SCALAR: Index (list), [0,-1] for all, [] internal count, -1 for last, *Default* = []
		- ident -> STR: Indentifier, *Default* = 'obj'
		"""
		
		bdata = {}
		hist_end = False
		
		for id in ident:
			bdata[id] = []
			if id in self.cues.keys():
				if isinstance(index,int):
					if (index == -1):
						index = len(self.cues[id])-1
					
					index = [index, index+1]
				elif isinstance(index,list):
					if (index == []):
						index = [self.icount[id], self.icount[id]+1]
						self.icount[id] += 1
					elif (index == [0,-1]):
						index = [0, len(self.cues[id])]
				else:
					raise ValueError('Index type not understood - must be either int or list')
			else:
				hist_end = True
				return (bdata,hist_end)
			for i in range(index[0],index[1]):
				
				#
				if (i >= len(self.cues[id])):
					hist_end = True
					return (bdata,hist_end)
				tvals = ARRAY.array('d')
				self.bin_file.seek(self.cues[id][i][0]*8,0)
				tvals.fromfile(self.bin_file,self.cues[id][i][1])
				bdata[id].append(numpy.array(tvals))
		
		return (bdata, hist_end)
		
		
	def write(self,bin_data,cue_data):
		
		"""
		Write Data to Optimizer History Files
		
		**Arguments:**
		
		- bin_data -> LIST/ARRAY: Data to be written to binary file
		- cue_data -> STR: Variable identifier for cue file
		"""        
		
		#
		bin_data = numpy.array(bin_data)
		tdata = ARRAY.array('d',bin_data.flatten())
		tdata.tofile(self.bin_file)
		self.bin_file.flush()
		
		# 
		self.cue_file.write('%d %d %s\n'%(self.s_count,len(bin_data.flatten()), cue_data))
		self.cue_file.flush()
		
		#
		self.s_count += len(bin_data.flatten())
		
		return
		
		
	def overwrite(self,bin_data,index):
		
		"""
		Overwrite Data on Optimizer History Files
		
		**Arguments:**
		
		- bin_data -> ARRAY: Data to overwrite old data
		- index -> INT: Starting index of old data
		"""
		
		#
		bin_data = numpy.array(bin_data)
		tdata = ARRAY.array('d',bin_data.flatten())
		self.bin_file.seek(index*8,0)
		tdata.tofile(self.bin_file)
		self.bin_file.flush()
		self.bin_file.seek(0,2)
		
		return
	



# Optimizer History Test
if __name__ == '__main__':
	
	# Test Optimizer History
	print('Testing Optimizer History...')
	hst = History()
	
