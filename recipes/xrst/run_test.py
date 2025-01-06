#! /usr/bin/env python
# The xrst automated test uses xrst to document itself using its source code.
# The program pytest/test_rst.py has an argument that determines 
# if the local verision or the installed version of xrst is tested.
#
# imports
import sys
import os
import subprocess
#
#
# prefix, name, version
prefix  = os.environ['PREFIX']
name    = os.environ['PKG_NAME']
version = os.environ['PKG_VERSION']
#
# url
home    = f'https://github.com/bradbell/{name}'
url     = f'{home}/archive/{version}.tar.gz'
#
# xrst-{version}.tar.gz
command = [ 'curl', '-LJO', url ]
print( ' '.join(command) )
subprocess.run( command , check = True)
#
# xrst-{version}
command = [ 'tar' , '-xzf', f'xrst-{version}.tar.gz' ]
print( ' '.join(command) )
subprocess.run( command , check = True)
os.chdir( f'xrst-{version}' )
#
# pytest/test_rst.py
test_installed_version = 'True'
command = [ 'python', 'pytest/test_rst.py', test_installed_version ]
print( ' '.join(command) )
subprocess.run( command , check = True)
#
print( 'run_test.py: OK' )
sys.exit(0)
