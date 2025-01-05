#! /usr/bin/env python
#
# imports
import sys
import os
import re
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
# file_name
file_name = 'pytest/test_rst.py'
#
# file_data
with open(file_name, 'r') as file_obj :
   file_data = file_obj.read()
#
# pattern
pattern = re.compile( r'test_installed_version *= *False' )
#
# Check that upstream source still satisifies assumsptions make below
m_obj   = pattern.search(file_data)
assert m_obj != None
m_obj   = pattern.search(file_data, m_obj.end() )
assert m_obj == None
#
# file_data
file_data = pattern.sub( r'test_installed_version = True',  file_data)
print( f'{file_name}: test_installed_version = True' )
#
# pytest/test_rst.py
with open(file_name, 'w') as file_obj :
   file_obj.write( file_data )
#
# pytest
command = [ 'pytest', '-s', 'pytest' ]
print( ' '.join(command) )
subprocess.run( command , check = True)
#
print( 'run_test.py: OK' )
sys.exit(0)
