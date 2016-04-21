#!/usr/bin/env python
"""
Main test harness for RIOS. 

Should be run as a main program. It then runs a selection 
of tests of some capabilities of RIOS. 

"""

if __name__ == '__main__':

    from rios.riostests import riostestutils
    riostestutils.testAll()
