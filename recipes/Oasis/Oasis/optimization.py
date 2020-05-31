"""
Optimization

Holds the Python Design Optimization Classes (base and inherited).

"""

__version__ = '$Revision: $'

import os#, sys
#import pdb


import numpy

from Oasis.variable import Variable
from Oasis.objective import Objective
from Oasis.constraint import Constraint
from Oasis.parameter import Parameter

inf = 10.E+20  # define a value for infinity



class Optimization(object):
    """
    Optimization Problem Class
    """

    def __init__(self, name, obj_fun, var_set=None, obj_set=None, con_set=None,
                 use_groups=False, *args, **kwargs):
        """
        Optimization Problem Class Initialization

        arguments:
            - name:
                [String] Solution name
            - obj_fun:
                [Function] Objective function
            - use_groups:
                [Boolen] Use of group identifiers flag, default None
            - var_set:
                [Instance] Variable set, default None
            - obj_set:
                [Instance] Objective set, default None
            - con_set:
                [Instance] Constraints set, default None
        """

        self.name = name
        self.obj_fun = obj_fun
        self.use_groups = use_groups

        # Initialize Variable Set
        if var_set is None:
            self.variables = {}
        else:
            self.variables = var_set

        self.vargroups = {}

        # Initialize Objective Set
        if obj_set is None:
            self.objectives = {}
        else:
            self.objectives = obj_set

        # Initialize Constraint Set
        if con_set is None:
            self.constraints = {}
        else:
            self.constraints = con_set

        # Initialize Solution Set
        self.solutions = {}

        # Flags for objective function calls about internal state of optimization
        self.is_gradient = False

        ## Initialize Parameter Set
        #if par_set is None:
        #    self._parameters = {}
        #else:
        #    self._parameters = par_set
        #self._pargroups = {}

    def getVar(self, i):
        """
        Get Variable *i* from Variables Set

        **Arguments:**

        - i -> INT: Variable index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Variable index must be an integer >= 0.")

        return self.variables[i]


    def addVar(self, *args, **kwargs):
        """
        Add Variable into Variables Set
        """

        id = self.firstavailableindex(self.variables)
        # setVar is going to use class Variable to create the variable i
        # args and kwargs has to follow the arguments of the Variable class
        self.setVar(id,*args,**kwargs)


        tmp_group = {}
        tmp_group[self.variables[id].name] = id
        # vargroups is a dictionary with the order of the group as a key
        # for each group a dict of the variable name as a key,
        self.vargroups[self.firstavailableindex(self.vargroups)] = {'name':self.variables[id].name,'ids':tmp_group}


    def addVarGroup(self, name, nvars, type='c', value=0.0, **kwargs):
        """
        Add a Group of Variables into Variables Set

        **Arguments:**

        - name -> STR: Variable Group Name
        - nvars -> INT: Number of variables in group

        **Keyword arguments:**

        - type -> STR: Variable type ('c'-continuous, 'i'-integer, 'd'-discrete), *Default* = 'c'
        - value ->INT/FLOAT: Variable starting value, *Default* = 0.0
        """

        #
        #ngroups = len(self._vargroups)
        #for j in xrange(ngroups):
        #    if (self._vargroups[j]['name'] == name):
        #        raise IOError('Variables group names should be distinct\n')

        #
        type = [type]*nvars

        if isinstance(value,list) or isinstance(value,numpy.ndarray):
            value = value
        elif isinstance(value,int):
            value = [value]*nvars
        elif isinstance(value,float):
            value = [value]*nvars
        else:
            raise IOError('Variable type for value not understood - use float, int or list\n')

        lower = [-inf]*nvars
        upper = [inf]*nvars
        choices = ['']*nvars

        for key in kwargs.keys():
            if (key == 'lower'):
                if isinstance(kwargs['lower'],float):
                    lower = [kwargs['lower']]*nvars
                elif isinstance(kwargs['lower'],int):
                    lower = [kwargs['lower']]*nvars
                elif isinstance(kwargs['lower'],(list,numpy.ndarray)):
                    if len(kwargs['lower']) != nvars:
                        for i in range(len(kwargs['lower'])):
                            lower[i] = kwargs['lower'][i]
                    else:
                        lower = kwargs['lower']
                else:
                    raise IOError('Variable type for lower bound not understood - use float, int or list\n')
            elif (key == 'upper'):
                if isinstance(kwargs['upper'],float):
                    upper = [kwargs['upper']]*nvars
                elif isinstance(kwargs['upper'],int):
                    upper = [kwargs['upper']]*nvars
                elif isinstance(kwargs['upper'],(list,numpy.ndarray)):
                    if len(kwargs['upper']) != nvars:
                        for i in range(len(kwargs['upper'])):
                            upper[i] = kwargs['upper'][i]
                    else:
                        upper = kwargs['upper']
                else:
                    raise IOError('Variable type for upper bound not understood - use float, int or list\n')
            if  (key == 'choices'):
                choices = [kwargs['choices']]*nvars

        tmp_group = {}
        for var in range(nvars):
            tmp_name = name +'_%s' %(var)
            id = self.firstavailableindex(self.variables)
            self.setVar(id, tmp_name, type[var], value[var], lower=lower[var], upper=upper[var], choices=choices[var])
            tmp_group[tmp_name] = id
        self.vargroups[self.firstavailableindex(self.vargroups)] = {'name':name,'ids':tmp_group}


    def setVar(self, i, *args, **kwargs):
        """
        Set Variable *i* into Variables Set

        Arguments:

			- i :
				[Integer]: Variable index
        """

        if len(args) > 0 and isinstance(args[0], Variable):
            self.variables[i] = args[0]
        else:
            try:
                # use the class Variable to create the variable i
                # args and kwargs has to follow the arguments of the Variable class
                self.variables[i] = Variable(*args,**kwargs)
            except IOError:
                raise
            except:
                raise ValueError("Input is not a Valid for a Variable Object instance\n")


    def delVar(self, i):
        """
        Delete Variable *i* from Variables Set

        **Arguments:**

        - i -> INT: Variable index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Variable index must be an integer >= 0.")

        del self.variables[i]


        #ngroups = len(self._vargroups)
        for j in self.vargroups.keys():
            keys = self.vargroups[j]['ids']
            nkeys = len(keys)
            for key in keys:
                if (self.vargroups[j]['ids'][key] == i):
                    del self.vargroups[j]['ids'][key]
                    if (nkeys == 1):
                        del self.vargroups[j]
                    return


    def delVarGroup(self, name):
        """
        Delete Variable Group *name* from Variables Set

        **Arguments:**

        - name -> STR: Variable group name
        """

        #
        ngroups = len(self.vargroups)
        for j in range(ngroups):
            if (self.vargroups[j]['name'] == name):
                keys = self.vargroups[j]['ids']
                for key in keys:
                    id = self.vargroups[j]['ids'][key]
                    del self.variables[id]
                del self.vargroups[j]


    def getVarSet(self):
        """
        Get Variables Set
        """

        return self.variables


    def getVarGroups(self):
        """
        Get Variables Groups Set
        """

        return self.vargroups


    def getObj(self, i):

        """
        Get Objective *i* from Objectives Set

        **Arguments:**

        - i -> INT: Objective index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Objective index must be an integer >= 0.")

        return self.objectives[i]


    def addObj(self, *args, **kwargs):

        """
        Add Objective into Objectives Set
        """

        #
        self.setObj(self.firstavailableindex(self.objectives),*args,**kwargs)


    def setObj(self, i, *args, **kwargs):
        """
        Set Objective *i* into Objectives Set

        **Arguments:**

        - i -> INT: Objective index
        """

        if (len(args) > 0) and isinstance(args[0], Objective):
            self.objectives[i] = args[0]
        else:
            try:
                self.objectives[i] = Objective(*args,**kwargs)
            except:
                raise ValueError("Input is not a Valid for a Objective Object instance\n")


    def delObj(self, i):
        """
        Delete Objective *i* from Objectives Set

        **Arguments:**

        - i -> INT: Objective index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Objective index must be an integer >= 0.")

        del self.objectives[i]


    def getObjSet(self):
        """
        Get Objectives Set
        """

        return self.objectives


    def getCon(self, i):
        """
        Get Constraint *i* from Constraint Set

        **Arguments:**

        - i -> INT: Constraint index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Constraint index must be an integer >= 0.")

        return self.constraints[i]


    def addCon(self, *args, **kwargs):
        """
        Add Constraint into Constraints Set
        """

        self.setCon(self.firstavailableindex(self.constraints),*args,**kwargs)


    def addConGroup(self, name, ncons, type='i', **kwargs):
        """
        Add a Group of Constraints into Constraints Set

        **Arguments:**

        - name -> STR: Constraint group name
        - ncons -> INT: Number of constraints in group

        **Keyword arguments:**

        - type -> STR: Constraint type ('i'-inequality, 'e'-equality), *Default* = 'i'
        """

        type_list = [type[0].lower()]*ncons

        if (type[0].lower() == 'i'):
            lower = [-inf]*ncons
            upper = [0.0]*ncons
            for key in kwargs.keys():
                if (key == 'lower'):
                    if isinstance(kwargs['lower'],float):
                        lower = [kwargs['lower']]*ncons
                    elif isinstance(kwargs['lower'],int):
                        lower = [kwargs['lower']]*ncons
                    elif isinstance(kwargs['lower'],(list,numpy.ndarray)):
                        if len(kwargs['lower']) != ncons:
                            for i in range(len(kwargs['lower'])):
                                lower[i] = kwargs['lower'][i]
                        else:
                            lower = kwargs['lower']
                    else:
                        raise IOError('Variable type for lower bound not understood - use float, int or list\n')
                elif (key == 'upper'):
                    if isinstance(kwargs['upper'],float):
                        upper = [kwargs['upper']]*ncons
                    elif isinstance(kwargs['upper'],int):
                        upper = [kwargs['upper']]*ncons
                    elif isinstance(kwargs['upper'],(list,numpy.ndarray)):
                        if len(kwargs['upper']) != ncons:
                            for i in range(len(kwargs['upper'])):
                                upper[i] = kwargs['upper'][i]
                        else:
                            upper = kwargs['upper']
                    else:
                        raise IOError('Variable type for upper bound not understood - use float, int or list\n')
            for con in range(ncons):
                tmp_name = name +'_%s' %(con)
                self.setCon(self.firstavailableindex(self.constraints),tmp_name, type_list[con], lower=lower[con], upper=upper[con])
        elif (type[0].lower() == 'e'):
            equal = [0.0]*ncons
            for key in kwargs.keys():
                if (key == 'equal'):
                    if isinstance(kwargs['equal'],float):
                        equal = [kwargs['equal']]*ncons
                    elif isinstance(kwargs['equal'],int):
                        equal = [kwargs['equal']]*ncons
                    elif isinstance(kwargs['equal'],(list,numpy.ndarray)):
                        if len(kwargs['equal']) != ncons:
                            for i in range(len(kwargs['equal'])):
                                lower[i] = kwargs['equal'][i]
                        else:
                            equal = kwargs['equal']
                    else:
                        raise IOError('Variable type for lower bound not understood - use float, int or list\n')
            for con in range(ncons):
                tmp_name = name +'_%s' %(con)
                self.setCon(self.firstavailableindex(self.constraints),tmp_name, type_list[con], equal=equal[con])


    def setCon(self, i, *args, **kwargs):
        """
        Set Constraint *i* into Constraints Set

        **Arguments:**

        - i -> INT: Constraint index
        """

        if (len(args) > 0) and isinstance(args[0], Constraint):
            self.constraints[i] = args[0]
        else:
            try:
                self.constraints[i] = Constraint(*args,**kwargs)
            except IOError:
                raise
            except:
                raise ValueError("Input is not a Valid for a Constraint Object instance\n")


    def delCon(self, i):
        """
        Delete Constraint *i* from Constraints Set

        **Arguments:**

        - i -> INT: Constraint index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Constraint index must be an integer >= 0.")

        del self.constraints[i]


    def getConSet(self):
        """
        Get Constraints Set
        """

        return self.constraints


    def getSol(self, i):
        """
        Get Solution *i* from Solution Set

        **Arguments:**

        - i -> INT: Solution index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Solution index must be an integer >= 0.")

        return self.solutions[i]


    def addSol(self, *args, **kwargs):
        """
        Add Solution into Solution Set
        """

        self.setSol(self.firstavailableindex(self.solutions),*args,**kwargs)


    def setSol(self,i, *args, **kwargs):
        """
        Set Solution *i* into Solution Set

        **Arguments:**

        - i -> INT: Solution index
        """

        if (len(args) > 0) and isinstance(args[0], Solution):
            self.solutions[i] = args[0]
        else:
            #try:
            self.solutions[i] = Solution(*args,**kwargs)
            #except:
            #	print args
            #	print kwargs
            #	raise ValueError("Input is not a Valid for a Solution Object instance\n")


    def delSol(self, i):

        """
        Delete *i* Solution from Solutions Set

        **Arguments:**

        - i -> INT: Solution index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Solution index must be an integer >= 0.")

        #
        del self.solutions[i]


    def getSolSet(self):
        """
        Get Solutions Set
        """

        return self.solutions


#    def getPar(self, i):
#
#        '''
#        Get Parameter *i* from Parameters Set
#
#        **Arguments:**
#
#        - i -> INT: Solution index
#        '''
#
#        # Check Index
#        if not (isinstance(i,int) and i >= 0):
#            raise ValueError("Parameter index must be an integer >= 0.")
#
#        #
#        return self._parameters[i]
#
#
#    def addPar(self, *args, **kwargs):
#
#        '''
#        Add Parameter into Parameters Set
#        '''
#
#        #
#        id = self.firstavailableindex(self._parameters)
#        self.setPar(id,*args,**kwargs)
#
#        #
#        tmp_group = {}
#        tmp_group[self._parameters[id].name] = id
#        self._pargroups[self.firstavailableindex(self._pargroups)] = {'name':self._parameters[id].name,'ids':tmp_group}
#
#
#    def setPar(self, i, *args, **kwargs):
#
#        '''
#        Set Parameter *i* into Parameters Set
#
#        **Arguments:**
#
#        - i -> INT: Parameter index
#        '''
#
#        #
#        if (len(args) > 0) and isinstance(args[0], Parameter):
#            self._parameters[i] = args[0]
#        else:
#            try:
#                self._parameters[i] = Parameter(*args,**kwargs)
#            except IOError, (error):
#                raise IOError("%s" %(error))
#            except:
#                raise ValueError("Input is not a Valid for a Parameter Object instance\n")
#
#
#    def delPar(self, i):
#
#        '''
#        Delete Parameter *i* from Parameters Set
#
#        **Arguments:**
#
#        - i -> INT: Parameter index
#        '''
#
#        # Check Index
#        if not (isinstance(i,int) and i >= 0):
#            raise ValueError("Parameter index must be an integer >= 0.")
#
#        #
#        del self._parameters[i]
#
#        #
#        for j in self._pargroups.keys():
#            keys = self._pargroups[j]['ids']
#            nkeys = len(keys)
#            for key in keys:
#                if (self._pargroups[j]['ids'][key] == i):
#                    del self._pargroups[j]['ids'][key]
#                    if (nkeys == 1):
#                        del self._pargroups[j]
#                    return
#
#
#    def delParGroup(self, name):
#
#        '''
#        Delete Parameter Group *name* from Parameters Set
#
#        **Arguments:**
#
#        - name -> STR: Parameter group name
#        '''
#
#        #
#        ngroups = len(self._pargroups)
#        for j in xrange(ngroups):
#            if (self._pargroups[j]['name'] == name):
#                keys = self._pargroups[j]['ids']
#                for key in keys:
#                    id = self._pargroups[j]['ids'][key]
#                    del self._parameters[id]
#                del self._pargroups[j]
#
#
#    def getParSet(self):
#
#        '''
#        Get Parameter Set
#        '''
#
#        return self._parameters
#
#
#    def getParGroups(self):
#
#        '''
#        Get Parameters Groups Set
#        '''
#
#        return self._pargroups


    def firstavailableindex(self, set):
        """
        List First Unused Index from Variable Objects List

        Arguments:

            - set:
                [List] List of the existed indeces, Set to find frist available
                index of
        """
        i = 0
        while i in set:
            i += 1

        return i


    def ListAttributes(self):
        """
        Print Structured Attributes List
        """

        ListAttributes(self)


    def __str__(self):
        """
        Print Structured Optimization Problem
        """

        text = '''\nOptimization Problem -- %s\n%s\n
        Objective Function: %s\n\n    Objectives:
        Name        Value        Optimum\n''' %(self.name,'='*80,self.obj_fun.__name__)
        for obj in self.objectives.keys():
            lines = str(self.objectives[obj]).split('\n')
            text += lines[1] + '\n'
        text += '''\n	Variables (c - continuous, i - integer, d - discrete):
        Name    Type       Value       Lower Bound  Upper Bound\n'''
        for var in self.variables.keys():
            lines = str(self.variables[var]).split('\n')
            text+= lines[1] + '\n'
        if len(self.constraints.keys()) > 0:
            text += '''\n	Constraints (i - inequality, e - equality):
        Name    Type                    Bounds\n'''
            for con in self.constraints.keys():
                lines = str(self.constraints[con]).split('\n')
                text+= lines[1] + '\n'

        return (text)


    def write2file(self, outfile='', disp_sols=False, **kwargs):
        """
        Write Structured Optimization Problem to file

        **Keyword arguments:**

        - outfile   ->  STR/INST: File name or file instance, *Default* = ''
        - disp_sols ->  BOOL: Display solutions flag, *Default* = False.
        - solutions ->  LIST: List of solution indexes.
        """

        if isinstance(outfile,str):
            if (outfile == ''):
                findir = os.listdir(os.curdir)
                tmpname = self.name.lower()
                tmpname = tmpname.split(' ')
                tmpname = tmpname[0]
                i = 0
                while (tmpname+'.txt') in findir:
                    tmpname = tmpname.rstrip('_%d' %(i-1))
                    tmpname = tmpname + '_' +str(i)
                    i += 1
                tmpname += '.txt'
                outfile = open(tmpname,'w')
            else:
                outfile = open(outfile,'w')
        elif (not isinstance(outfile,str)) and (not isinstance(outfile,file)):
            raise IOError(repr(outfile) + 'is not a file or filename')
        ftext = self.__str__()
        outfile.write(ftext)
        if disp_sols or 'solutions' in kwargs:
            if 'solutions' in kwargs:
                sol_indices = kwargs['solutions']
            else:
                sol_indices = self.solutions.keys()
            for key in sol_indices:
                soltext = '\n' + self.solutions[key].__str__()
                outfile.write(soltext)
        print('Data written to file ', outfile.name)
        outfile.close()


    def solution(self, i):
        """
        Get Solution from Solution Set

        **Arguments:**

        - i -> INT: Solution index
        """

        # Check Index
        if not (isinstance(i,int) and i >= 0):
            raise ValueError("Solution index must be an integer >= 0.")

        return self.solutions[i]



class Solution(Optimization):
    """
    Optimization Solution Class
    """

    def __init__(self, optimizer, name, obj_fun, opt_time, opt_evals,
                 opt_inform, var_set=None, obj_set=None, con_set=None,
                 options_set=None, myrank=0,*args, **kwargs):

        """
        Solution Class Initialization

        Arguments:
            - optimizer :
                [String]: Optimizer name
            - name :
                [String] Optimization problem name
            - opt_time :
                    [Float]: Solution total time
            - opt_evals :
                [NTEGER] Number of function evaluations
            - var_set :
                [Instance] Variable set, Default = {}
            - obj_set :
                [Instance] Objective set, Default = {}
            - con_set :
                [Instance] Constraints set, Default = {}
            - options_set :
                Options used for solution, Default = {}
            - myrank :
                [Instance] Process identification for MPI evaluations,
                    Default = 0
        """

        Optimization.__init__(self, name, obj_fun, var_set, obj_set, con_set, *args, **kwargs)
        self.optimizer = optimizer
        self.opt_time = opt_time
        self.opt_evals = opt_evals
        self.opt_inform = opt_inform
        self.options_set = options_set
        self.myrank = myrank

        if 'display_opts' in kwargs:
            self.display_opt = kwargs['display_opts']
            del kwargs['display_opts']
        else:
            self.display_opt = False
        self.parameters = kwargs


    def __str__(self):
        """
        Print Structured Solution
        """

        text0 = Optimization.__str__(self)
        text1 = ''
        lines = text0.split('\n')
        lines[1] = lines[1][len('Optimization Problem -- '):]
        for i in range(5):
            text1 += lines[i] + '\n'
        if self.display_opt:
            text1 += '\n	Options:\n '
            opt_keys = self.options_set.keys()
            opt_keys.sort()
            for key in opt_keys:
                ns = 25-len(key)
                text1 += '		'+ key +':' + str(self.options_set[key][1]).rjust(ns,'.') + '\n'
        text1 += '\n    Solution: \n'
        text1 += ('-'*80) + '\n'
        text1 += '    Total Time: %25.4f\n' %(self.opt_time)
        text1 += '    Total Function Evaluations: %9.0i\n' %(self.opt_evals)
        for key in self.parameters.keys():
            if (isinstance(self.parameters[key],(dict,list,tuple))) and (len(self.parameters[key]) == 0):
                continue
            elif (isinstance(self.parameters[key],numpy.ndarray)) and (0 in (self.parameters[key]).shape):
                continue
            else:
                text1 += '    '+ key +': ' + str(self.parameters[key]).rjust(9) + '\n'
        for i in range(5,len(lines)):
            text1 += lines[i] + '\n'
        text1 += ('-'*80) + '\n'

        if (self.myrank == 0):
            return text1
        else:
            return ''


    def write2file(self, outfile):
        """
        Write Structured Solution to file

        **Arguments:**

        - outfile -> STR: Output file name
        """

        Optimization.write2file(self,outfile,False)



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



# Optimization Test
if __name__ == '__main__':

    print('Testing Optimization...')
    optprob = Optimization('Optimization Problem',{})
    optprob.ListAttributes()