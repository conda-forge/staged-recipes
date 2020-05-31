"""
Optimizer

Holds the Python Design Optimization Classes (base and inherited).

"""

__version__ = '$Revision: $'




#import os, sys
#import pdb

from Oasis.optimization import Optimization
from Oasis.history import History

inf = 10.E+20  # define a value for infinity


class Optimizer(object):
    """
    Abstract Class for Optimizer Object
    """

    def __init__(self, name={}, category={}, def_options={}, informs={},
                 *args, **kwargs):
        """
        Optimizer Class Initialization

        Keyword arguments:

        - name :
            [String]: Optimizer name, Default = {}
        - category :
            [String]: Optimizer category, Default = {}
        - def_options :
            [Dictionary]: Deafult options, Default = {}
        - informs :
            [Dictionary]: Calling routine informations texts, Default = {}
        """

        self.name = name
        self.category = category
        self.options = {}
        self.options['defaults'] = def_options
        self.informs = informs

        # Initialize Options
        def_keys = def_options.keys()
        for key in def_keys:
            self.options[key] = def_options[key]

        koptions = kwargs.pop('options',{})
        kopt_keys = koptions.keys()
        for key in kopt_keys:
            self.setOption(key,koptions[key])

    def __solve__(self, opt_problem={}, *args, **kwargs):
        """
        Run Optimizer (Optimizer Specific Routine)

        **Keyword arguments:**

        - opt_problem -> INST: Optimization problem instance, *Default* = {}
        """
        pass


    def __call__(self, opt_problem={}, *args, **kwargs):
        """
        Run Optimizer (Calling Routine)

        Arguments:

        - opt_problem :
            [Instance]: Optimization problem instance, Default = {}

            Additional arguments and keyword arguments are passed to the
            objective function call
        """

        # Check Optimization Problem
        if not isinstance(opt_problem,Optimization):
            try:
                hasattr(opt_problem,'constraints')
            except:
                raise ValueError("Input is not a Valid Optimization Problem Instance\n")

        # Check order of Constraints - equality constraint has to come
        # before inequality constraint
        last_eq = 0
        first_ieq = -1

        if len(opt_problem.constraints.keys()) > 0 :
            for key in opt_problem.constraints.keys():
                # equality constraint
                if opt_problem.constraints[key].type == 'e':
                    last_eq = int(key)
                # inequality constraint
                elif opt_problem.constraints[key].type == 'i':
                    if first_ieq == -1:
                        first_ieq = int(key)

            if last_eq > first_ieq and first_ieq != -1:
                print('WARNING - Equality Constraints should be defined BEFORE Inequality Constraints')

        # Solve Optimization Problem
        return self.__solve__(opt_problem, *args, **kwargs)


    def _on_setOption(self, name, value):
        """
        Set Optimizer Option Value (Optimizer Specific Routine)

        **Arguments:**

        - name -> STR: Option name
        - value ->   : Option value
        """

        raise NotImplementedError()


    def setOption(self, name, value=None):
        """
        Set Optimizer Option Value (Calling Routine)

        **Arguments:**

        - name -> STR: Option Name

        **Keyword arguments:**

        - value -> FLOAT/INT/BOOL: Option Value, *Default* = None
        """

        def_options = self.options['defaults']
        if name in def_options:
            if (type(value) == def_options[name][0]):
                self.options[name] = [type(value),value]
            else:
                raise IOError('Incorrect ' + repr(name) + ' value type')
        else:
            raise IOError(repr(name) + ' is not a valid option name')

        self._on_setOption(name, value)

    def _on_getOption(self, name):
        """
        Get Optimizer Option Value (Optimizer Specific Routine)

        **Arguments:**

        - name -> STR: Option name
        """
        raise NotImplementedError()

    def getOption(self, name):
        """
        Get Optimizer Option Value (Calling Routine)

        **Arguments:**

        - name -> STR: Option name
        """

        def_options = self.options['defaults']
        if name in def_options:
            return self.options[name][1]
        else:
            raise IOError(repr(name) + ' is not a valid option name')

        self._on_getOption(name)


    def _on_getInform(self, info):
        """
        Get Optimizer Result Information (Optimizer Specific Routine)

        **Arguments:**

        - info -> STR: Information key
        """
        raise NotImplementedError()

    def getInform(self, infocode=None):
        """
        Get Optimizer Result Information (Calling Routine)

        **Keyword arguments:**

        - infocode -> INT: information code key
        """

        if (infocode == None):
            return self.informs
        else:
            return self._on_getInform(infocode)

    def _on_flushFiles(self):
        """
        Flush Output Files (Optimizer Specific Routine)
        """

        raise NotImplementedError()

    def flushFiles(self):
        """
        Flush Output Files (Calling Routine)
        """

        self._on_flushFiles()

    def _setHistory(self, probname, store_hst, hot_start, def_fname):
        """
        Setup Optimizer History and/or Hot-start instances

        Arguments:

        - probname :
            [String] Optimization problem name
        - store_hst :
            [Boolen/String] Flag/filename to store optimization history
        - hot_start :
            [Boolen/String] Flag/filename to read optimization history
        - def_fname :
            [String]: Default file name
        """

        myrank = self.myrank

        hos_file = None
        log_file = None
        tmp_file = False
        if myrank == 0:
            # store_hst is a string
            # hot_start is a string
            if isinstance(store_hst,str):
                if isinstance(hot_start,str):
                    if (store_hst == hot_start):
                        hos_file = History(hot_start, 'r', self)
                        log_file = History(store_hst+'_tmp', 'w', self, probname)
                        tmp_file = True
                    else:
                        hos_file = History(hot_start, 'r', self)
                        log_file = History(store_hst, 'w', self, probname)

                    self.sto_hst = True
                    self.hot_start = True
                elif hot_start:
                # store_hst is a string
                # hot_start is a Boolen(True)
                    hos_file = History(store_hst, 'r', self)
                    log_file = History(store_hst+'_tmp', 'w', self, probname)
                    self.sto_hst = True
                    self.hot_start = True
                    tmp_file = True
                else:
                # store_hst is a string
                # hot_start is a Boolen(False)
                    log_file = History(store_hst, 'w', self, probname)
                    self.sto_hst = True
                    self.hot_start = False
            # store_hst is a boolen(True)
            # hot_start is string
            elif store_hst:
                if isinstance(hot_start,str):
                    if (hot_start == def_fname):
                        hos_file = History(hot_start, 'r', self)
                        log_file = History(def_fname+'_tmp', 'w', self, probname)
                        tmp_file = True
                    else:
                        hos_file = History(hot_start, 'r', self)
                        log_file = History(def_fname, 'w', self, probname)
                    self.sto_hst = True
                    self.hot_start = True
                # store_hst is a boolen(True)
                # hot_start is boolen(True)
                elif hot_start:
                    hos_file = History(def_fname, 'r', self)
                    log_file = History(def_fname+'_tmp', 'w', self, probname)
                    self.sto_hst = True
                    self.hot_start = True
                    tmp_file = True
                else:
                # store_hst is a boolen(True)
                # hot_start is boolen(False)
                    log_file = History(def_fname, 'w', self, probname)
                    self.sto_hst = True
                    self.hot_start = False
            else:
            # store_hst is a boolen(False)
            # hot_start is string
                if isinstance(hot_start,str):
                    hos_file = History(hot_start, 'r', self)
                    self.hot_start = True
                elif hot_start:
                    hos_file = History(def_fname, 'r', self)
                    self.hot_start = True
                else:
                    self.hot_start = False

                self.sto_hst = False

        else:
            self.sto_hst = False
            self.hot_start = False

        return hos_file, log_file, tmp_file

    def ListAttributes(self):
        """
        Print Structured Attributes List
        """

        ListAttributes(self)



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



# Optimizer Test
if __name__ == '__main__':

    # Test Optimizer
    print('Testing Optimizer...')
    opt = Optimizer()
    opt.ListAttributes()

