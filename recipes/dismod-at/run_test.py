#! /usr/bin/env python
#
# test_file
# This file must be in the test.sources of recipe.yaml
test_file = 'test/user/db2csv.py'
#
# imports
import sys
import os
import subprocess
#
# system_command
# 1. print the command before executing it
# 2. double check for errors during the command
# 3 print any error message that is returned before aborting
def system_command(command) :
   print( " ".join( command ) )
   try :
      result = subprocess.run(
         command, 
         check          = False,
         capture_output = True , 
         encoding       = 'utf-8', 
         env            = os.environ
      )
   #
   except subprocess.CalledProcessErrror as e :
      if e.stdout != None and e.stdout != "" :
         print( e.stdout )
      sys.exit( e.stderr )
   #
   if result.stdout != None and result.stdout != "" :
      print( result.stdout )
   if result.returncode != 0 :
      sys.exit( result.stderr )
   return result.stdout
#
# main
# Put this code in a function so as to not polute the file namespace
def main() :
   #
   # prefix
   prefix  = os.environ['PREFIX'].replace('/', '|').replace('\\', '|')
   print( f'run_test.py:\nprefix with /, \\ repalced by | = {prefix}' )
   #
   # env_path
   env_path  = os.environ['PATH']
   print( f'run_test.py:\nenv_path = {env_path}' )
   #
   # sys.path
   print( f'run_test.py:\nsys.path = {sys.path}' )
   #
   # test_file
   assert test_file[-3 :] == '.py'
   if not os.path.isfile(test_file) :
      sys.exit( f'run_test.py: cannot find test file = {test_file}' )
   #
   # file_data
   with open( test_file, 'r') as file_obj :
      file_data = file_obj.read()
   #
   # ../../devel/dismod_at -> dismod_at
   # Change execuable from sandbox verison to installed version
   file_data = file_data.replace('../../devel/dismod_at', 'dismod_at' )
   #
   # python_exe python/bin/dismodat.py -> dismod-at
   # Change script from sandbox verison to installed version
   file_data = file_data.replace('python_exe,\n', '' )
   file_data = file_data.replace('python/bin/dismodat.py', 'dismod-at')
   #
   # test_copy
   test_copy = 'test_copy.py'
   file_data = file_data.replace(test_file, test_copy)
   with open(test_copy , 'w') as file_obj :
      file_obj.write(file_data)
   #
   # run test_copy 
   command = [ 'python', test_copy ] 
   system_command( command )
   #
   print( sys.argv[0] + ': OK' )
#
#
# python main
if __name__ == "__main__" :
   main()
