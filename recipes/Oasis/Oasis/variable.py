"""
variable

Holds the Python Design Optimization Classes (base and inherited).
"""

__version__ = '$Revision: $'



#import os, sys
#import pdb


inf = 10.E+20  # define a value for infinity


class Variable(object):

    """
    ============================================
        Optimization Variable Class
    ============================================
    """

    def __init__(self, name, type='c', value=0.0, *args, **kwargs):
        
        """
        Variable Class Initialization

        Arguments:
            - name:
                [String]: Variable Name
            - type:
                [String]: Variable Type ('c'-continuous, 'i'-integer,
                        'd'-discrete), *Default* = 'c'
            - value:
                [numeric]: Variable Value, Default = 0.0
            - lower:
                [numeric]: Variable Lower Value
            - upper:
                [numeric]: Variable Upper Value
            - choices:
                [List]: Variable Choices
        """
        # name of the variable
        self.name = name
        # type of the variable c,i or d
        self.type = type[0].lower()
        
        
        ### C - Continuous variable 
        if (type[0].lower() == 'c'):
            self.value = float(value)
            self.lower = -inf
            self.upper = inf
            
            for key in kwargs.keys():
                if (key == 'lower'):
                    self.lower = float(kwargs['lower'])
                    if self.lower < -inf:
                        self.lower = -inf
                if (key == 'upper'):
                    self.upper = float(kwargs['upper'])
                    if self.upper > inf:
                        self.upper = inf
        
        ### i - Integer variable
        elif (type[0].lower() == 'i'):
            self.value = int(value)
            self.lower = []
            self.upper = []
            for key in kwargs.keys():
                if (key == 'lower'):
                    self.lower = int(kwargs['lower'])

                if (key == 'upper'):
                    self.upper = int(kwargs['upper'])


            if self.lower == []:
                raise IOError('An integer variable requires to input a lower bound value')

            if self.upper == []:
                raise IOError('An integer variable requires to input an upper bound value')
                
        ### d - Discrete variable
        elif (type[0].lower() == 'd'):
            for key in kwargs.keys():
                if (key == 'choices'):
                    self.choices = kwargs['choices']
                else:
                    raise IOError('A discrete variable requires to input an array of choices')


            try:
                self.value = self.choices[int(value)]
            except:
                raise IOError('A discrete variable requires the value input to be a integer pointer value of the choices array')

            self.lower = int(0)
            self.upper = int(len(self.choices))
        else:
            raise IOError('Variable type not understood -- use either c(ontinuous), i(nteger) or d(iscrete)')



    def ListAttributes(self):

        """
        Print Structured Attributes List
        """

        ListAttributes(self)


    def __str__(self):

        """
        Print Structured List of Variable
        """

        if (self.type == 'd'):
            return ('Name    Type       Value       Lower Bound  Upper Bound\n'+'	 '+str(self.name).center(9) +'%5s	%14f %14.2e %12.2e \n' %(self.type, self.choices[int(self.value)], min(self.choices), max(self.choices)))
        else:
            return ('Name    Type       Value       Lower Bound  Upper Bound\n'+'	 '+str(self.name).center(9) +'%5s	%14f %14.2e %12.2e \n' %(self.type, self.value, self.lower, self.upper))





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

    # Test Variable
    var = Variable('x')
    var.ListAttributes()

