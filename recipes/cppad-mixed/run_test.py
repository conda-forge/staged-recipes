#! /usr/bin/env python
#
# example_file
# This file must be in the test.sources of meta.yaml
example_file = 'example/user/no_random.cpp'
#
# eigen_version
eigen_version = '3.4.0'
#
# imports
import sys
import os
import subprocess
import platform
#
# system_command
def system_command(command) :
   print( " ".join( command ) )
   try :
      result = subprocess.run(
         command, 
         check = False,
         capture_output = True , 
         encoding = 'utf-8', 
         env = os.environ
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
def main() :
   #
   # prefix
   prefix  = os.environ['PREFIX']
   print( f'prefix = {prefix}' )
   #
   # cxx_compiler
   cxx_compiler = os.environ['CXX']
   print( f'cxx_compiler = {cxx_compiler}' )
   #
   # system
   system = platform.system()
   assert system in [ 'Linux', 'Darwin', 'Windows' ]
   #
   if system != 'Linux' :
      print( f'run_test.py: Skiping {system} system' )
      return
   #
   # example_file
   assert example_file[-4 :] == '.cpp'
   #
   # example_function
   start            = example_file.rfind('/') + 1
   example_function = example_file[start : -4] + '_xam'
   #
   # main.cpp
   data = '''
# include <iostream>
# include <cstdlib>
extern bool EXAMPLE_FUNCTION(void); 

int main(void)
{  if( ! EXAMPLE_FUNCTION() )
   {  std::cout << "EXAMPLE_FUNCTION: Error" << std::endl;
      std::exit(1);
   }
   std::cout << "EXAMPLE_FUNCTION: OK" << std::endl;
   std::exit(0);
}
'''
   data = data.replace( 'EXAMPLE_FUNCTION', example_function )
   with open('main.cpp', 'w') as fobj :
      fobj.write(data)
   #
   # main 
   env = os.environ
   env['LD_LIBRARY_PATH'] = f'{prefix}/lib'
   command = [ 
      cxx_compiler, 'main.cpp', example_file ,
      '-I', f'{prefix}/include',
      '-I', f'{prefix}/include/eigen3',
      '-L', f'{prefix}/lib',
      '-lcppad_mixed',
      '-o', 'main'
   ]
   system_command( command )
   #
   # main
   system_command( [ './main' ] )
   #
   print( 'run_test.py: OK' )
#
if __name__ == "__main__" :
   main()
