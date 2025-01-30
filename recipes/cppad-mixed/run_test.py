#! /usr/bin/env python
#
# example_file
# This file must be in the test.sources of meta.yaml
example_file = 'example/user/no_random.cpp'
#
# cxx_compiler
# This compiler is requires for testing in meta.yaml
cxx_compiler = 'clang++'
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
def main() :
   #
   # eigen-version
   # The eigen include files are in the build environment, but not the
   # test environment, so we make a separate copy of its source.
   url  =  'https://gitlab.com/libeigen/eigen/-/archive'
   url += f'/{eigen_version}/eigen-{eigen_version}.tar.gz'
   command = [ 'curl', '-LJO', url ]
   print( " ".join( command ) )
   result = subprocess.run(command, check = True)
   command = [ 'tar' , '-xzf', f'eigen-{eigen_version}.tar.gz' ]
   print( ' '.join(command) )
   subprocess.run( command , check = True)
   #
   # prefix
   prefix  = os.environ['PREFIX']
   print( f'prefix = {prefix}' )
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
      '-I', f'eigen-{eigen_version}',
      '-I', f'{prefix}/include',
      '-L', f'{prefix}/lib',
      '-lcppad_mixed',
      '-o', 'main'
   ]
   print( " ".join( command ) )
   subprocess.run(command, check = True , env = env)
   #
   # main
   command = [ './main' ]
   print( " ".join( command ) )
   subprocess.run(command, check = True )
   #
   print( 'run_test.py: OK' )
#
if __name__ == "__main__" :
   main()
