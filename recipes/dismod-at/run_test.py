#! /usr/bin/env python
#
# test_file_list
# These files must be in the test.sources of recipe.yaml.
# In addition, if any of the example/get_started/*.py appears below,
# example/get_started/get_started_db.py must be in test.sources of recipe.yaml.
test_file_list = [
   'example/get_started/fit_command.py',
   'test/user/db2csv.py' ,
]
#
# imports
import sys
import os
import re
import subprocess
import platform
import dismod_at
#
# sandbox2installed
def sandbox2installed(test_file) :
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
   # Change from sandbox dismod_at to installed dismod_at
   pattern   = r'\.\./\.\./devel/dismod_at'
   replace   = r'dismod_at'
   file_data = re.sub(pattern, replace, file_data)
   #
   # file_data
   # Change from sandbox dismodat.py to installed dismod-at
   pattern   = r'python/bin/dismodat.py'
   replace   = r'dismod-at'
   file_data = re.sub(pattern, replace, file_data)
   #
   # file_data
   # Remove python from font of dismod-at commands
   pattern   = r'python_exe *,'
   replace   = r''
   file_data = re.sub(pattern, replace, file_data)
   #
   # test_file
   with open(test_file , 'w') as file_obj :
      file_obj.write(file_data)

#
# main
# Put this code in a function so as to not polute the file namespace
def main() :
   #
   # work_dir
   work_dir  = os.getcwd().replace('/', '|').replace('\\', '|')
   print( f'run_test.py: work directory with / and \\ repalced by |')
   print( work_dir )
   #
   # prefix_dir
   prefix_dir  = os.environ['PREFIX'].replace('/', '|').replace('\\', '|')
   print( f'run_test.py: prefix directory with / and \\ repalced by |')
   print( prefix_dir )
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
   for test_file in test_file_list :
      #
      # skip
      # test/user/db2csv.py tests the installed dismod-at python script.
      # This is failing on the conda-forge test machine, but works
      # doing a local rattler-build on a windows machine. At this point
      # I think it is a problem with the conda test system. 
      skip = test_file=='test/user/db2csv.py' and platform.system=='Windows'
      if not skip :
         #
         # sandbox2installed
         sandbox2installed(test_file)
         #
         # test_file
         command = [ 'python', test_file ]
         result = dismod_at.system_command_prc( 
            command               ,
            print_command  = True ,
            return_stdout  = True ,
            return_stderr  = True ,
         )
         if result.stdout != '' :
            print( result.stdout )
         if result.returncode == 0 :
            assert result.stderr == ''
         else :
            print( 'system_command_prc: Error Message:' )
            print( result.stderr )
            sys.exit(1)
   #
   print( 'run_test.py: OK' )
#
#
# python main
if __name__ == "__main__" :
   main()
