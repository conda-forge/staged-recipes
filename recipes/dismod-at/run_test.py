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
import platform
#
# system_command
# 1. print the command before executing it
# 2. double check for errors during the command
# 3. if an error occurs, exit with message
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
      if e.stdout == None or e.stdout == "" :
         sys.exit('run_test.py: command above failed with no error message')
      sys.exit( e.stderr )
   #
   if result.stdout != None and result.stdout != "" :
      print( result.stdout )
   if result.returncode != 0 :
      if result.stdout == None or result.stdout == "" :
         sys.exit('run_test.py: command above failed with no error message')
      sys.exit( result.stderr )
#
# main
# Put this code in a function so as to not polute the file namespace
def main() :
   #
   # prefix
   prefix  = os.environ['PREFIX'].replace('/', '|').replace('\\', '|')
   print( f'run_test.py: prefix with / and \\ repalced by |')
   print( prefix )
   #
   # sys.path
   print( f'run_test.py: sys.path =\n{sys.path}' )
   #
   # sys.argv[0]
   print( f'run_test.py: sys.argv[0] = {sys.argv[0]}' )
   #
   # platform.system
   print( 'run_test.py: platform.system() = ', platform.system() )
   #
   # dismod_at, dismod-at
   dir_list  = os.environ['PATH'].replace(';', ':').split(':')
   for directory in dir_list :
      for file_name in [ 'dismod_at', 'dismod-at' ] :
         file_path = f'{directory}/{file_name}'
         if os.path.isfile( file_path ) :
            print( f'run_test.py: found {file_path}' )
         if platform.system() == 'Windows' :
            for extension in [ 'exe', 'bat' ] :
               if os.path.isfile( f'{file_path}.{extension}' ) :
                  print( f'run_test.py: found {file_path}.{extension}' )
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
   # file_data
   # Change from sandbox dismod_at verison to installed version
   file_data = file_data.replace('../../devel/dismod_at', 'dismod_at' )
   #
   # file_data
   # Change script from sandbox dismod-at to installed version
   file_data = file_data.replace('python_exe,\n', '' )
   file_data = file_data.replace('python/bin/dismodat.py', 'dismod-at')
   #
   # test_file
   with open(test_file , 'w') as file_obj :
      file_obj.write(file_data)
   #
   # test_file 
   command = [ 'python', test_file ] 
   system_command( command )
   #
   print( 'run_test: OK' )
#
#
# python main
if __name__ == "__main__" :
   main()
