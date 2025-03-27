#! /usr/bin/env python
#
# example_file
# This file must be in the test.sources of recipe.yaml
example_file = 'example/user/fit_fixed_both.py'
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
   prefix  = os.environ['PREFIX'].replace('/', '|').replace('\\', '|');
   print( f'run_test.py:\nprefix with / and \\ repalced by / = {prefix}' )
   #
   # sys.path
   for path in sys.path :
      if path.endswith('site-packages') :
         print( f'os.listdir( {path} )' )
         print( sorted( os.listdir(path) ) )
   #
   # example_file
   assert example_file[-3 :] == '.py'
   if not os.path.isfile(example_file) :
      sys.exit( f'run_test.py: cannot find example file = {example_file}' )
   #
   # file_data
   with open( example_file, 'r') as file_obj :
      file_data = file_obj.read()
   # change execuable from sandbox verison to installed version
   file_data = file_data.replace('../../devel/dismod_at', 'dismod_at' )
   #
   # example_copy
   example_copy = 'example_copy.py'
   file_data = file_data.replace(example_file, example_copy)
   with open(example_copy , 'w') as file_obj :
      file_obj.write(file_data)
   #
   # run example_copy 
   command = [ 'python', example_copy ] 
   system_command( command )
   #
   print( 'run_test.py: OK' )
#
#
# python main
if __name__ == "__main__" :
   main()
