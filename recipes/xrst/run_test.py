#! /usr/bin/env python3
# ----------------------------------------------------------------------------
import re
import os
import sys
import urllib.request
import tarfile
import shutil
import pytest
#
# prefix, name, version
prefix  = os.environ['PREFIX']
name    = os.environ['PKG_NAME']
version = os.environ['PKG_VERSION']
#
# url
home = f'https://github.com/bradbell/{name}'
url  = f'{home}/archive/{version}.tar.gz'
#
# url_data
response = urllib.request.urlopen(url)
url_data = response.read()
#
# file_name, xrst-{version}.tar.gz
file_name = f'xrst-{version}.tar.gz'
file_obj  = open(file_name, 'wb')
file_obj.write( url_data )
file_obj.close()
#
# xrst-version
tar_obj = tarfile.open(file_name, "r:gz" )
tar_obj.extractall()
tar_obj.close()
os.chdir( f'xrst-{version}' )
#
# file_data
# is the contents of xrst-version/pytest/test_rst.py in the source
file_name = 'pytest/test_rst.py'
file_obj  = open(file_name, 'r')
file_data = file_obj.read()
file_obj.close()
#
# file_data
# 1. Run the installed version of xrst.
# 2. Suppress spelling warnings because conda is using a newer 
#    version of the pyenchant spell checker.
pattern   = re.compile( "'python3' *, *'-m' *, *'xrst' *," )
m_obj     = pattern.search(file_data)
assert m_obj != None
replace   = f"'{prefix}/bin/xrst', '--suppress_spell_warnings', "
file_data = pattern.sub(replace, file_data)
#
# xrst-version/pytest/test_rst.py
# version used by pytest to test xrst.
file_name = 'pytest/test_rst.py'
file_obj  = open(file_name, 'w')
file_obj.write(file_data)
file_obj.close()
#
# file_data
# is the contents of xrst-version/xrst.toml
file_name = 'xrst.toml'
file_obj  = open(file_name, 'r')
file_data = file_obj.read()
file_obj.close()
#
# file_data
# Change pyenchant to pyspellchecker; see
# https://github.com/conda-forge/pyenchant-feedstock/issues/1
pattern   = re.compile( 'pyenchant' )
m_obj     = pattern.search(file_data)
assert m_obj != None
replace   = 'pyspellchecker'
file_data = pattern.sub(replace, file_data)
#
# xrst-version/xrst.toml
# version used druing pytest of xrst.
file_name = 'xrst.toml'
file_obj  = open(file_name, 'w')
file_obj.write(file_data)
file_obj.close()
#
# pytest
# use assert to make sure that the test passes.
retcode = pytest.main( [ '-s', 'pytest' ] )
assert retcode == 0
#
print( 'run_test.py: OK' )
